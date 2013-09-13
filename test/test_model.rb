# test/model.rb
require_relative "test_helper"

class TestModel < Rulers::Model::FileModel
  
  def self.sample_data
    _ = { 
      "submitter" => "Jeff",
      "quote" => "A penny saved is a penny earned.",
      "attribution" => "Ben Franklin"
    }
  end
  
  def fetch_data(pathname)
    data = TestModel.sample_data
    json = "{"
    data.each_with_index { | elem, index | 
      json += "\"" + elem[0].to_s + "\": "
      json += "\"" + elem[1].to_s + "\""
      
      if (index < data.length-1)
        json += ","
      end
    }
    json += "}"
  end
end

class RulersModelTest < Test::Unit::TestCase
  
  # once the public interface gets matured, delete this test.
  def test_WHEN_initialized__FileModel_contains_an_id__pathname
    model = TestModel.new("db/quotes/1.json")
  
    assert_equal 1, model.instance_variable_get(:@id)
    assert_equal "db/quotes/1.json", model.instance_variable_get(:@pathname)
  end
  
  # once the public interface gets matured, delete this test.
  def test_WHEN_initialized__FileModel_contains_a_hash_of_properties_from_record
    model = TestModel.new("db/quotes/1.json")

    hash = model.instance_variable_get(:@hash)
    assert_not_nil hash, "@hash was not set in model"
    assert_equal TestModel.sample_data, hash
  end
end