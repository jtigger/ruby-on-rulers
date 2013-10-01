require_relative "test_helper"

class TestCoreExt < Test::Unit::TestCase
  def test_GIVEN_a_controller_name_url__String_to_camel_case__converts_to_the_class_name_prefix
    controller_name_url = "a_controller_with_multiple_words_in_its_name"
    assert_equal "AControllerWithMultipleWordsInItsName", controller_name_url.to_camel_case
  end
end
