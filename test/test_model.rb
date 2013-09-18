# test/model.rb
require_relative "test_helper"

class TestModel < Rulers::Model::FileModel
  @@sample_data = [
    { 
      "submitter" => "Jeff",
      "quote" => "A penny saved is a penny earned.",
      "attribution" => "Ben Franklin"
    },
    { 
      "submitter" => "John",
      "quote" => "Enjoy the people and the process, THESE are the good old days.",
      "attribution" => "Stu Ryan"
    },
    { 
      "submitter" => "Jeff",
      "quote" => "37% of all statistics are made up on the spot.",
      "attribution" => "Anonymous"
    },
    { 
      "submitter" => "Fred",
      "quote" => "Do unto others as you'd like them to do unto you.",
      "attribution" => "Anonymous"
    },
    { 
      "submitter" => "John",
      "quote" => "I'm not afraid of death, I just don't want to be there when it happens.",
      "attribution" => "Woody Allen"
    }
  ]
  def self.sample_data(id)
    _ = @@sample_data[id]
  end
    
  def hash_to_json(hash)
    json = "{"
    hash.each_with_index { | elem, index | 
      json += "\"" + elem[0].to_s + "\": "
      json += "\"" + elem[1].to_s + "\""
      
      if (index < hash.length-1)
        json += ","
      end
    }
    json += "}"
  end  

  def self.warmup_cache_with_sample_data
    (0..@@sample_data.count-1).each { |id| TestModel.new("db/quotes/#{id}.json") }
  end
  
  def fetch_data(pathname)
    id = Rulers::Model::FileModel.get_id_from_pathname pathname
    data = TestModel.sample_data id
    hash_to_json data
  end

  def self.find_all
    @@cache.values
  end

  # this line MUST appear at the bottom of the class definition as it relies on overriden behavior.
  self.warmup_cache_with_sample_data
end

class RulersModelTest < Test::Unit::TestCase
  
  # once the public interface gets matured, delete this test.
  def test_WHEN_initialized__FileModel_contains_an_id__pathname
    model = TestModel.new("db/quotes/0.json")
  
    assert_equal 0, model.instance_variable_get(:@id)
    assert_equal "db/quotes/0.json", model.instance_variable_get(:@pathname)
  end
  
  # once the public interface gets matured, delete this test.
  def test_WHEN_initialized__FileModel_contains_a_hash_of_properties_from_record
    model = TestModel.new("db/quotes/0.json")

    hash = model.instance_variable_get(:@hash)
    assert_not_nil hash, "@hash was not set in model"
    assert_equal TestModel.sample_data(0), hash
  end
  
  def test_FileModel_caches_instances_of_models
    first_record = TestModel.find 1
    first_record_again = TestModel.find 1
    
    assert_same first_record, first_record_again, "Expected both instances would be the exact same object"
  end
  
  def test_can_find_models_by_submitter
    models = TestModel.find_all_by_submitter "Jeff"
    
    assert_equal 2, models.size, "Expected to fetch 2 quotes submitted by Jeff."
  end
  
  def test_can_find_models_by_attribution
    models = TestModel.find_all_by_attribution "Woody Allen"

    assert_equal 1, models.size, "Expected to fetch 1 quote attributed to Woody Allen"
  end
end