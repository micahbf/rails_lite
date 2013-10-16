class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    req.request_method.downcase.to_sym == @http_method
      && req.path =~ @pattern
  end

  def run(req, res)
  end
end

class Router
  attr_reader :routes

  def initialize
  end

  def add_route(pattern, method, controller_class, action_name)
  end

  def draw(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    # add these helpers in a loop here
  end

  def match(req)
  end

  def run(req, res)
  end
end
