$LOAD_PATH << __dir__ << File.join(__dir__, "lib")
ENV["RACK_ENV"] ||= "development"

require "bundler"
Bundler.setup(:default, ENV["RACK_ENV"])

require "sequel"

module Rsvg2heroku
  def self.db
    @db ||= Sequel.connect(ENV.fetch("DATABASE_URL"))
  end
end

Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :touch
Sequel::Model.raise_on_save_failure = false

DB = Rsvg2heroku.db
DB.extension :pg_hstore
DB.extension :pg_array
DB.extension :pagination

require "rsvg2heroku/app"
