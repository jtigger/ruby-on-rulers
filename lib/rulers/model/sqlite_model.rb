# lib/rulers/model/sqlite_model.rb

module Rulers
  module Model
    class SQLiteModel
      def self.connect(path_to_db)
        @db = SQLite3::Database.new path_to_db
      end
      
      def self.table
        name.to_snake_case.gsub /_model$/, ''
      end
      
      def self.schema
        @schema = {}
        @db.table_info(table) do |row|
          @schema[row["name"]] = row["type"]
        end
        @schema
      end

      def self.to_sql(value)
        case value
        when Numeric
          value.to_s
        when String
          "'#{value}'"
        else
          raise "Unable to map #{value.class} to SQL."
        end
      end
    end
  end
end