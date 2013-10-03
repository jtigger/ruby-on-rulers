# test/test_sqlite_model.rb
require_relative "test_helper"
require "sqlite3"

class TestSqliteModel < Rulers::Model::SQLiteModel
  
end

class RulersSQLiteModelTest < Test::Unit::TestCase
  def setup
    @build_test_temp_dir = "build/test"
    database_filename = "#{@build_test_temp_dir}/test.db"

    `mkdir -p #{@build_test_temp_dir}`
    conn = SQLite3::Database.new database_filename
    conn.execute_batch <<__
    create table test_sqlite (
      id     INTEGER PRIMARY KEY,
      name   VARCHAR(30)
    );
__
    
  end
  
  def teardown
    `rm -rf #{@build_test_temp_dir}`
  end
  
  def test_Model_classname_matches_backing_table_name
    assert_equal "test_sqlite", TestSqliteModel.table
  end
end

