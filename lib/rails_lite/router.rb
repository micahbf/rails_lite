class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    req.request_method.downcase.to_sym == @http_method &&
      req.path =~ @pattern
  end

  def run(req, res)
    matches = @pattern.match(req.path) || {}
    params = Hash[matches.names.map(&:to_sym).zip(matches.captures)]
    controller = @controller_class.new(req, res, params)
    controller.invoke_action(@action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(path_string, method, controller_class, action_name)
    path_regex = Regexp.new("^" + path_string.gsub(/(:([^\/]+))/, '(?<\2>[^/]+)') + "$")
    @routes << Route.new(path_regex, method, controller_class, action_name)
  end

  def draw(&proc)
    self.instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |path_string, controller_class, action_name|
      add_route(path_string, http_method, controller_class, action_name)
    end
  end

  def match(req)
    @routes.find { |rt| rt.matches?(req) }
  end

  def run(req, res)
    route = match(req)
    if route
      route.run(req, res)
    else
      res.status = 404
    end
  end
end
