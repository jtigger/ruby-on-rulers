# lib/rulers/model/sqlite_model.rb

module Rulers
  module Model
    
    # Generates valid SQL strings, suitable to execute against a SQLite database.
    class SQLiteDialect
      def initialize(table_name, schema)
        @table_name = table_name
        @schema = schema
      end
      
      def to_sql(value)
        case value
        when Hash
          quoted_values = value.keys.map do |key|
            if @schema.keys.include?(key.to_s) || @schema.keys.include?(key.to_sym)
              value_for_key = value[key]
              [key, to_sql(value_for_key)]
            end
          end
          Hash[quoted_values]
        when Numeric
          value.to_s
        when String
          "'#{value}'"
        when nil
          "NULL"
        else
          raise "Unable to map #{value} (an instance of #{value.class}) to SQL."
        end
      end
      
      def sql_for_create(column_value_pairs)
        "INSERT INTO #{@table_name} (#{column_value_pairs.keys.join(", ")}) values (#{column_value_pairs.values.join(", ")});"
      end
      
      def sql_for_get_id
        "SELECT last_insert_rowid();"
      end
    end
    
    class SQLiteModel
      def self.connect(path_to_db)
        @db = SQLite3::Database.new path_to_db
        @dialect = SQLiteDialect.new table, schema
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
        insert_sql = @dialect.sql_for_create Hash[schema.keys.zip(@dialect.to_sql(values))]
        puts insert_sql
        @db.execute insert_sql
        id = @db.execute(@dialect.sql_for_get_id)[0][0]
        self.new
      end
      
    end
  end
end