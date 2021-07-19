# frozen_string_literal: true

module Config
  ROOT_DIR = File.expand_path("#{__dir__}/../")

  DATA_DIR = File.join(ROOT_DIR, "data")
  DATA_FILE_NAME = "sqr_20656_MRP_speeding_citations_for_msp_for_2016_2019.xlsx"
  DATA_FILE_PATH = File.join(DATA_DIR, DATA_FILE_NAME)

  DB_DIR = File.join(ROOT_DIR, "db")
  DB_FILE_NAME = "citations.db"
  DB_FILE_PATH = File.join(DB_DIR, DB_FILE_NAME)

  EXPORTED_VARS = [
    :root_dir,
    :data_dir, :data_file_name, :data_file_path,
    :db_dir, :db_file_name, :db_file_path
  ]

  extend self

  EXPORTED_VARS.each do |var|
    define_method(var) do
      const_get(var.upcase.to_sym)
    end
  end

  def to_h
    EXPORTED_VARS.to_h do |var|
      [var, send(var)]
    end
  end
end
