# frozen_string_literal: true

class Database
  attr_reader :path

  def initialize(path: nil)
    @path ||= Config.db_file_path
  end

  def conn
    @conn ||= SQLite3::Database.new(path)
  end

  def down
    conn.execute("DROP TABLE IF EXISTS citations;")
  end

  def up
    create_citations
  end

  def recreate
    down
    up
  end

  def transaction
    conn.transaction
    yield
    conn.commit
  end

  def insert_all(table_name, rows)
    cols = rows.first.keys

    col_list = cols.join(", ")

    rows_as_values = rows.map do |row|
      row_to_values(table_name, row)
    end
    rows_as_sql = rows_as_values.map { |s| "(#{s.join(", ")})" }.join(",\n")

    template = "INSERT INTO #{table_name} (#{col_list}) VALUES #{rows_as_sql}"

    conn.execute(template)
  end

  def create_citations
    conn.execute_batch(<<~SQL)
      CREATE TABLE citations (
        agency              varchar(200),
        date                date,
        time                time,
        location            varchar(200),
        offense_code        varchar(50),
        offense_description varchar(200),
        posted_speed        integer,
        violation_speed     integer
      );

      CREATE INDEX ix_citations_date_time ON citations (date, time);
      CREATE INDEX ix_citations_speed ON citations (posted_speed, violation_speed);
    SQL
  end

  def table_schema(table)
    # We're not writing an ORM here, but if we did:
    # conn.execute("pragma table_info(#{table_name});")
    raise NotImplementedError unless table == :citations

    {
      agency: { type: :string },
      date: { type: :date },
      time: { type: :time },
      location: { type: :string },
      offense_code: { type: :string },
      offense_description: { type: :string },
      posted_speed: { type: :integer },
      violation_speed: { type: :integer },
    }
  end

  private

  def row_to_values(table_name, row)
    schema = table_schema(table_name)

    row.map do |name, value|
      safe_value(value, schema.dig(name, :type))
    end
  end

  def safe_value(value, type)
    return nil if value.nil?

    case type
    when :string
      escape(value)
    when :integer
      value.to_i
    when :date
      formatted = value.is_a?(::Date) ? value.iso8601 : value
      escape(formatted)
    when :time
      formatted = value.is_a?(::Time) ? value.strftime("%H:%M") : value
      escape(formatted)
    else
      raise NotImplementedError, "No support for #{type}"
    end
  end

  def escape(string)
    return nil if string.nil?

    "'" + string.to_s.gsub("'", "''") + "'"
  end
end
