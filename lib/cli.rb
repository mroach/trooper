# frozen_string_literal: true

class TrooperCLI < Thor
  desc "by_speed LIMIT", "Report citations by speed"
  option :format
  def by_speed(limit)
    results = db.conn.execute(<<~SQL, limit)
      SELECT  violation_speed, COUNT(*)
      FROM    citations
      WHERE   posted_speed = ?
      GROUP BY violation_speed
      ORDER BY violation_speed
    SQL

    puts format_results(results)
  end

  desc "by_excess", "Citations by excess of speed limit"
  def by_excess
    results = db.conn.execute(<<~SQL)
      SELECT  violation_speed - posted_speed, COUNT(*)
      FROM    citations
      GROUP BY 1
      ORDER BY 1
    SQL

    puts format_results(results)
  end

  desc "by_year", "Citation count by year"
  def by_year
    results = db.conn.execute(<<~SQL)
      SELECT  strftime('%Y', date), COUNT(*)
      FROM    citations
      GROUP BY 1
    SQL

    puts format_results(results)
  end

  desc "by_month", "Citation count by month"
  def by_month
    results = db.conn.execute(<<~SQL)
      SELECT  strftime('%m', date), COUNT(*)
      FROM    citations
      GROUP BY 1
    SQL

    puts format_results(results)
  end

  desc "by_day_of_week", "Citation count by day of week"
  def by_day_of_week
    results = db.conn.execute(<<~SQL)
      SELECT  strftime('%w', date), COUNT(*)
      FROM    citations
      GROUP BY 1
    SQL

    puts format_results(results)
  end

  desc "by_day_of_month", "Citation count by day of week"
  def by_day_of_month
    results = db.conn.execute(<<~SQL)
      SELECT  strftime('%d', date), COUNT(*)
      FROM    citations
      GROUP BY 1
    SQL

    puts format_results(results)
  end

  desc "by_location", "Citation count by location (city)"
  def by_location
    results = db.conn.execute(<<~SQL)
      SELECT  location, COUNT(*)
      FROM    citations
      GROUP BY 1
      ORDER BY location
    SQL

    puts format_results(results)
  end

  private

  def format_results(results)
    out_format = options.fetch(:format, "tab")

    case out_format
    when "tab"
      to_tab(results)
    when "csv"
      to_csv(results)
    else
      raise ArgumentError, "Unsupported format '#{out_format}'"
    end
  end

  def to_tab(results)
    results.map { |row| row.join("\t") }.join("\n")
  end

  def to_csv(results)
    require "csv"

    CSV.generate do |csv|
      results.each do |row|
        csv << row
      end
    end
  end

  def db
    @db ||= Database.new
  end
end
