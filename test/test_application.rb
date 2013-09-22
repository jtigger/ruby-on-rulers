require_relative "test_helper"

class TestApp < Rulers::Application
end

# Aspect that captures when the controller is constructed, allowing our tests to inspect the controller that processed the request.
module Rulers
  class Controller
    @@latest = nil
    
    # Idiom: clean method override; see also: https://gist.github.com/jtigger/6660651#file-clean_method_override-rb
    old_initialize = instance_method(:initialize)
    define_method(:initialize) do |*args|
      old_initialize.bind(self).(*args)
      @@latest = self
    end
    
    def self.latest
      @@latest
    end
  end
end

class RulersAppTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    TestApp.new
  end

  def test_WHEN_client_requests_favicon_THEN_returns_404
    get '/favicon.ico'
    
    assert_equal 404, last_response.status
  end
  
  def test_WHEN_params_are_included_in_the_get_THEN_those_are_available_from_the_controller
    get '/testing/show?id=1'
    
    assert_equal '1', Rulers::Controller.latest.request.params["id"]
  end
end
class TestingController < Rulers::Controller
  def show
  end
end

class RulersAppTest
  def test_WHEN_client_requests_root_THEN_redirects_to_home_page
    get "/"
    assert_equal 302, last_response.status

    follow_redirect!
    assert_equal 200, last_response.status
    body = last_response.body
    assert body["This is the home page."]
  end
end
class HomeController < Rulers::Controller
  def index
    "This is the home page."
  end
end

class RulersAppTest
  def test_WHEN_client_requests_a_templated_resource_THEN_that_template_is_rendered
    get "/template/index"
    
    assert_equal 200, last_response.status
    assert_equal "bar", last_response.body
  end
end
class TemplateController < Rulers::Controller
  def index
    render :view, { :foo => "bar" }
  end

  def get_template_contents(view_name)
    "<%= foo %>"
  end
end

class RulersAppTest
  def test_WHEN_an_error_occurs_while_rendering_THEN_returns_HTTP_error
    get "/exception/index"
    
    assert_equal 500, last_response.status
  end
end
class ExceptionController < Rulers::Controller
  def index
    raise "Mock exception."
  end
end


class RulersAppTest
  def test_WHEN_an_instance_variable_is_declared_on_the_controller_THEN_that_value_is_available_in_the_view
    get "/parameterized/index"
    
    assert_equal "The answer to life, The Universe, and everything is 42.", last_response.body
  end
end
class ParameterizedController < Rulers::Controller
  def initialize(args)
    @some_ivar = 42
  end
  
  def index
    render :view
  end
  
  def get_template_contents(view_name)
    "The answer to life, The Universe, and everything is <%= some_ivar %>."
  end
end

class RulersAppTest
  def test_WHEN_request_includes_posted_params_THEN_application_has_those_params
    expected_params = { "foo" => "bar" }
    post "/posting/index", expected_params
    
    assert_equal expected_params, last_request.params
  end
end
class PostingController < Rulers::Controller
end



