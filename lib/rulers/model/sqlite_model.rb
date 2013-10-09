# lib/rulers/model/sqlite_model.rb

module Rulers
  module Model
    
    # Generates valid SQL strings, suitable to execute against a SQLite database.
    class SQLiteDialect
      def initialize(schema)
        @schema = schema
      end
      
      def to_sql(value)
        case value
        when Hash
          keys = @schema.keys - ["id"]
          keys.map do |key|
            value_for_key = value[key]
            value_for_key = value[key.to_sym] if !value_for_key
            to_sql(value_for_key)
          end
        when Numeric
          value.to_s
        when String
          "'#{value}'"
        when nil
          "NULL"
        else
          raise "Unable to map #{value.class} to SQL."
        end
      end
      
      
    end
    
    class SQLiteModel
      def self.connect(path_to_db)
        @db = SQLite3::Database.new path_to_db
        @dialect = SQLiteDialect.new schema
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
      
      def self.create(values)
        # SQL escape values
        # generate SQL for insert
        # execute insert
        # obtain ID    select_rowid_sql = "SELECT last_insert_rowid();"; @db.execute select_rowid_sql
        # "unescape" SQL into Model values
        # scatter results into an Model instance variables
        
        insert_sql = sql_for_create Hash[schema.keys.zip(to_sql(values))]
        @db.execute insert_sql
      end
      
      def self.sql_for_create(column_value_pairs)
        "INSERT INTO #{table} (#{column_value_pairs.keys.join(", ")}) values (#{column_value_pairs.values.join(", ")});"
      end
    end
  end
end