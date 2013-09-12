require_relative "test_helper"

class TestApp < Rulers::Application
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
