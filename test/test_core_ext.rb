require_relative "test_helper"

class TestCoreExt < Test::Unit::TestCase
  def test_GIVEN_a_controller_name_url__String_to_camel_case__converts_to_the_class_name_prefix
    controller_name_url = "a_controller_with_multiple_words_in_its_name"
    assert_equal "AControllerWithMultipleWordsInItsName", controller_name_url.to_camel_case
  end
end

module TestClasses
end

class ClassExtTest < Test::Unit::TestCase
  def setup
    TestClasses.module_eval "class Foo; end; class Bar < Foo; end;"
    @foo = TestClasses::Foo.new
    @bar = TestClasses::Bar.new
  end
  
  def teardown
    TestClasses.send(:remove_const, "Bar")
    TestClasses.send(:remove_const, "Foo")
  end
  
  def test_class_attribute__creates_variable_reader_on_base_class
    TestClasses::Foo.class_eval "class_attribute :ree"
    assert_nil TestClasses::Foo.ree
  end
  def test_class_attribute__creates_variable_reader_on_subclass
  end
  def test_class_attribute__GIVEN_subclass_has_no_value_defined_THEN_assignments_to_variable_applies_to_both_base_class_and_subclass
  end
  def test_class_attribute__GIVEN_subclass_HAS_a_value_defined_THEN_assignments_to_variable_applies_to_only_subclass
  end
end