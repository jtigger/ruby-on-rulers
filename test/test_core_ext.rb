require_relative "test_helper"

class TestCoreExt < Test::Unit::TestCase
  def test_GIVEN_a_controller_name_url__String_to_camel_case__converts_to_the_class_name_prefix
    controller_name_url = "a_controller_with_multiple_words_in_its_name"
    assert_equal "AControllerWithMultipleWordsInItsName", controller_name_url.to_camel_case
  end
end

module TestClasses
end


class ModuleExtTest < Test::Unit::TestCase
  def setup
    TestClasses.module_eval "class Foo; end"
    @foo = TestClasses::Foo.new
  end
  
  def teardown
    @foo = nil
    TestClasses.send(:remove_const, "Foo")
  end
  
  def test_GIVEN_a_method_is_defined_on_a_module_THEN_remove_possible_method_undefines_it
    TestClasses::Foo.class_eval do
      public; def public_bar; nil; end
      protected; def protected_bar; nil; end
      private; def _private_bar; nil; end
    end
    
    assert TestClasses::Foo.method_defined?(:public_bar)
    assert TestClasses::Foo.method_defined?(:protected_bar)
    assert TestClasses::Foo.private_method_defined?(:_private_bar)
    
    TestClasses::Foo.class_eval do
      remove_possible_method :public_bar
      remove_possible_method :protected_bar
      remove_possible_method :_private_bar
    end
    
    assert !TestClasses::Foo.method_defined?(:public_bar), "expected method 'public_bar' to be removed, but it's still there."
    assert !TestClasses::Foo.method_defined?(:protected_bar), "expected method 'protected_bar' to be removed, but it's still there."
    assert !TestClasses::Foo.private_method_defined?(:_private_bar), "expected method '_private_bar' to be removed, but it's still there."
  end
  
  def test_GIVEN_a_method_is_NOT_defined_on_a_module_THEN_remove_possible_method_quietly_ignores
    TestClasses::Foo.class_eval do
      def ree
      end
    end
    foo = TestClasses::Foo.new
    assert !foo.respond_to?(:bar)
    
    TestClasses::Foo.class_eval do
      remove_possible_method :bar
    end
    
    assert !foo.respond_to?(:bar), "expected method 'bar' to be removed, but it's still there."
  end
end

class ClassExtTest < Test::Unit::TestCase
  def setup
    TestClasses.module_eval "class Foo; end"
    TestClasses.module_eval "class Bar < Foo; end"
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
    TestClasses::Foo.class_eval "class_attribute :ree"
    assert_nil TestClasses::Bar.ree
  end
  
  def test_class_attribute__GIVEN_subclass_has_no_value_defined_THEN_assignments_to_variable_applies_to_both_base_class_and_subclass
    TestClasses::Foo.class_eval "class_attribute :ree"
    
    TestClasses::Foo.ree = 42
    
    assert_equal 42, TestClasses::Foo.ree, "assignment failed for the base class"
    assert_equal 42, TestClasses::Bar.ree, "assignment worked for the base class, but not the subclass"
  end
  
  def test_class_attribute__GIVEN_subclass_HAS_a_value_defined_THEN_assignments_to_variable_applies_to_only_subclass
    TestClasses::Foo.class_eval "class_attribute :ree"
    
    TestClasses::Foo.ree = 42
    TestClasses::Bar.ree = 157
    
    assert_equal 42, TestClasses::Foo.ree, "assignment failed for the base class"
    assert_equal 157, TestClasses::Bar.ree, "assignment worked for the base class, but not the subclass"
  end
end