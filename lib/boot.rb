# frozen_string_literal: true
require "bundler/inline"

gemfile do
  source "https://rubygems.org"

  # XLSX parser
  gem "xsv", "~> 1.0"

  gem "sqlite3", "~> 1.4"

  gem "thor", "~> 1.1", require: false
end

load File.join(__dir__, "config.rb")
load File.join(__dir__, "db.rb")
load File.join(__dir__, "importer.rb")
