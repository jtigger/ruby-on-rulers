# test/test_sqlite_model.rb
require_relative "test_helper"
require "sqlite3"

class TestSqliteModel < Rulers::Model::SQLiteModel; end

class RulersSQLiteModelTest < Test::Unit::TestCase

  # GIVEN: a concrete subclass of SQLiteModel, connected to a real table with a few columns on it...
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
  
  def test_WHEN_generating_sql_SQLiteModel_translates_integer_values_to_strings
    assert_equal "42", TestSqliteModel.to_sql(42)
  end
  
  def test_WHEN_generating_sql_SQLiteModel_surrounds_strings_with_single_quotes
    assert_equal "'Hello, world!'", TestSqliteModel.to_sql("Hello, world!")
  end
  
  def test_WHEN_generating_sql_SQLiteModel_translates_nil_to_null
    assert_equal "NULL", TestSqliteModel.to_sql(nil)
  end
  
  def test_WHEN_generating_sql_SQLiteModel_escapes_hashes_of_values
    values = { :name => "Lily G", :age => 0, :tagline => "Ooooooooohhh!" }
    sql_escaped_values = ["'Lily G'", "0", "'Ooooooooohhh!'"]
    
    assert_equal sql_escaped_values, TestSqliteModel.to_sql(values)
  end

  def test_WHEN_generating_sql_SQLiteModel_inserts_null_for_missing_values
    values = { :name => "Lily G",
             # :age => 0,   -- this value is intentionally removed
               :tagline => "Ooooooooohhh!" }
    sql_escaped_values = ["'Lily G'", "NULL", "'Ooooooooohhh!'"]
    
    assert_equal sql_escaped_values, TestSqliteModel.to_sql(values)
  end
  
  def test_WHEN_generating_sql_to_create_a_new_model_SQLiteModel_emits_a_SQL_insert
    expected_sql = "INSERT INTO test_sqlite (name, age, tagline) values ('Lily G', 0, 'Ooooooooohhh!');"
    values = { :name => "'Lily G'", :age => '0', :tagline => "'Ooooooooohhh!'" }
    
    assert_equal expected_sql, TestSqliteModel.sql_for_create(values)
  end

end

