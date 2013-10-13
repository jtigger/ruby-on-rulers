# test/test_sqlite_model.rb
require_relative "test_helper"
require "sqlite3"
require "contest"

class TestSqliteModel < Rulers::Model::SQLiteModel; end

class RulersSQLiteModelTest < Test::Unit::TestCase
  class << self
    alias_method :given, :context
    alias_method :which_means, :setup
  end

  given "a concrete subclass of SQLiteModel, connected to a real table with a few columns on it," do
    which_means do
      @build_test_temp_dir = "build/test"
      database_filename = "#{@build_test_temp_dir}/test.db"

      `mkdir -p #{@build_test_temp_dir}`
      conn = SQLite3::Database.new database_filename
      conn.execute_batch <<__
      drop table if exists test_sqlite;
      create table test_sqlite (
        id      INTEGER PRIMARY KEY,
        name    VARCHAR(30),
        age     INTEGER,
        tagline VARCHAR(80)
      );
__
      TestSqliteModel.connect database_filename
    end
  
    teardown do
      `rm -rf #{@build_test_temp_dir}`
    end
    
    test "assumes the backing table matches the classname" do
      assert_equal "test_sqlite", TestSqliteModel.table
    end
    
    test "reads the schema straight from the database" do
      expected_schema = { "id" => "INTEGER", "name" => "VARCHAR(30)", "age" => "INTEGER", "tagline" => "VARCHAR(80)"}
      assert_equal expected_schema, TestSqliteModel.schema
    end
    
    given "and using the SQLiteDialect to generate SQL" do
      which_means do
        @dialect = Rulers::Model::SQLiteDialect.new(TestSqliteModel.table, TestSqliteModel.schema)
      end

      test "translates integer values to strings" do
        assert_equal "42", @dialect.to_sql(42)
      end
      
      test "surrounds strings with single quotes" do
        assert_equal "'Hello, world!'", @dialect.to_sql("Hello, world!")
      end

      test "translates nil to null" do
        assert_equal "NULL", @dialect.to_sql(nil)
      end

      test "translates hashes into hashes of translated values" do
        values = { :name => "Lily G", :age => 0, :tagline => "Ooooooooohhh!" }
        sql_escaped_values = { :name => "'Lily G'", :age => "0", :tagline => "'Ooooooooohhh!'"}

        assert_equal sql_escaped_values, @dialect.to_sql(values)
      end
      
      test "given a hash of translated values, generates a valid SQL INSERT statement" do
        expected_sql = "INSERT INTO test_sqlite (name, age, tagline) values ('Lily G', 0, 'Ooooooooohhh!');"
        translated_values = { :name => "'Lily G'", :age => '0', :tagline => "'Ooooooooohhh!'" }

        assert_equal expected_sql, @dialect.sql_for_create(translated_values)
      end
      
      test "generates the SQL required to get the ID of the just-inserted row" do
        assert_equal "SELECT last_insert_rowid();", @dialect.sql_for_get_id
      end
    end
    given "and with a hash of values, create a persisted instance of TestSqliteModel," do
      which_means do
        values = { :name => "Lily G", :age => 0, :tagline => "Ooooooooohhh!" }
    
        @model = TestSqliteModel.create values
      end
      
      test "assigns a valid id to the model" do
        assert_not_nil @model[:id]
        assert @model[:id].to_i > 0  # valid = positive integer
      end
      
      test "populates the model with the values from the hash" do
        assert_equal "Lily G", @model[:name]
        assert_equal 0, @model[:age]
        assert_equal "Ooooooooohhh!", @model[:tagline]
      end
    end
  end
end

