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
      
      def sql_for_update(values)
        quoted_values = to_sql(values)
        quoted_id = quoted_values.delete(:id)
        set_clause = quoted_values.map { |column, quoted_value| "#{column} = #{quoted_value}" }.join(", ")
        "UPDATE #{@table_name} SET #{set_clause} WHERE id = #{quoted_id};"
      end
      
      def sql_for_get_id
        "SELECT last_insert_rowid();"
      end
      
      def sql_for_table_size
        "SELECT COUNT(*) from #{@table_name};"
      end
      
      def sql_for_find_by_id(id)
        projection_list = @schema.keys
        ["SELECT #{projection_list.join(", ")} FROM #{@table_name} WHERE id = #{id}", projection_list]
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
        insert_sql = @dialect.sql_for_create @dialect.to_sql(values)
        @db.execute insert_sql
        id = @db.execute(@dialect.sql_for_get_id)[0][0]
        new({ :id => id }.merge(values))
      end
      
      def self.find_by_id(id)
        select_sql, projection_list = @dialect.sql_for_find_by_id(id)
        rows = @db.execute select_sql
        values = Hash[projection_list.map {|column_name| column_name.to_sym}.zip(rows[0])]
      end

      def self.count
        @db.execute(@dialect.sql_for_table_size)[0][0]
      end

      def [](attribute)
        @values[attribute] if @values
      end
      
      def []=(attribute, new_value)
        @values[attribute] = new_value 
      end
      
      # def save
      #   dialect = SQLiteModel.instance_variable_get(:@dialect)
      #   update_sql = dialect.sql_for_update @values
      # end
            
      protected
      def initialize(values)
        @values = values
      end
    end
  end
end