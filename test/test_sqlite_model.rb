# test/test_sqlite_model.rb
require_relative "test_helper"
require "sqlite3"

class TestSqliteModel < Rulers::Model::SQLiteModel; end

class RulersSQLiteModelTest < Test::Unit::TestCase
  def setup
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
  
  def teardown
    `rm -rf #{@build_test_temp_dir}`
  end
  
  def test_SQLiteModel_assumes_the_backing_table_matches_the_classname
    assert_equal "test_sqlite", TestSqliteModel.table
  end
    
  def test_SQLiteModel_reads_the_schema_straight_from_the_database
    expected_schema = { "id" => "INTEGER", "name" => "VARCHAR(30)", "age" => "INTEGER", "tagline" => "VARCHAR(80)"}
    assert_equal expected_schema, TestSqliteModel.schema
  end
  
  def test_WHEN_generating_sql_SQLiteModel_translates_integer_values_to_Strings
    assert_equal "42", TestSqliteModel.to_sql(42)
  end
  
  def test_WHEN_generating_sql_SQLiteModel_surrounds_strings_with_single_quotes
    assert_equal "'Hello, world!'", TestSqliteModel.to_sql("Hello, world!")
  end
end

