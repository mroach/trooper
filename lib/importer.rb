# frozen_string_literal: true

class Importer
  attr_reader :data_file_path, :db

  def initialize
    @data_file_path = Config.data_file_path
    @db = Database.new
  end

  def import!
    db.transaction do
      sheet.each_slice(200).each do |rows|
        groomed_rows = rows.map { |row| groom_row(row) }

        db.insert_all(:citations, groomed_rows)

        print(".")
      end
    end

    puts "Done."
  end

  def groom_row(row)
    {
      agency: row[0].strip,
      date: row[1].iso8601,
      time: convert_time(row[2], row[3], row[4]),
      location: row[5],
      offense_code: row[6],
      offense_description: row[7],
      posted_speed: row[8],
      violation_speed: row[9],
    }
  end

  def workbook
    @workbook ||= Xsv::Workbook.open(data_file_path)
  end

  def sheet
    @sheet ||= begin
      sheet = workbook.sheets[0]
      sheet.row_skip = 1
      sheet
    end
  end

  private

  def convert_time(hour, minute, am_pm)
    hour = hour.to_i
    hour += 12 if am_pm == "PM"

    format("%02i:%02i", hour, minute.to_i)
  end
end
