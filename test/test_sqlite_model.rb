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
    
    test "SQLiteModel assumes the backing table matches the classname" do
      assert_equal "test_sqlite", TestSqliteModel.table
    end
    
    test "SQLiteModel reads the schema straight from the database" do
      expected_schema = { "id" => "INTEGER", "name" => "VARCHAR(30)", "age" => "INTEGER", "tagline" => "VARCHAR(80)"}
      assert_equal expected_schema, TestSqliteModel.schema
    end
    
    given "and using the SQLiteDialect to generate SQL" do
      which_means do
        @dialect = Rulers::Model::SQLiteDialect.new(TestSqliteModel.schema)
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

      test "translates entire hashes of values" do
        values = { :name => "Lily G", :age => 0, :tagline => "Ooooooooohhh!" }
        sql_escaped_values = ["'Lily G'", "0", "'Ooooooooohhh!'"]

        assert_equal sql_escaped_values, @dialect.to_sql(values)
      end
      
      test "when translating hashes, inserts null for missing values" do
        values = { :name => "Lily G",
                 # :age => 0,   -- this value is intentionally removed
                   :tagline => "Ooooooooohhh!" }
        sql_escaped_values = ["'Lily G'", "NULL", "'Ooooooooohhh!'"]

        assert_equal sql_escaped_values, @dialect.to_sql(values)
      end
    end
  
    test "When generating SQL, to create a new model SQLiteModel emits a SQL insert" do
      expected_sql = "INSERT INTO test_sqlite (name, age, tagline) values ('Lily G', 0, 'Ooooooooohhh!');"
      values = { :name => "'Lily G'", :age => '0', :tagline => "'Ooooooooohhh!'" }
    
      assert_equal expected_sql, TestSqliteModel.sql_for_create(values)
    end
  end
end

