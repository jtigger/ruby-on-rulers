# lib/rulers/model/sqlite_model.rb

module Rulers
  module Model
    class SQLiteModel
      def self.table
        name.to_snake_case.gsub /_model$/, ''
      end
    end
  end
end