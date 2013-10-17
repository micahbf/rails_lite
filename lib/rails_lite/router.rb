require "active_support/inflector"

class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name, :name

  def initialize(pattern, http_method, controller_class, action_name, name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
    @name = name
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
    @base_path = ""
  end

  def add_route(path_string, method, controller_class, action_name, route_name)
    path_regex = Regexp.new("^" + path_string.gsub(/(:([^\/]+))/, '(?<\2>[^/]+)') + "$")
    @routes << Route.new(path_regex, method, controller_class, action_name, route_name)
  end

  def draw(&proc)
    self.instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |path_string, controller_class, action_name, route_name|
      add_route(path_string, http_method, controller_class, action_name, route_name)
    end
  end

  def match(req)
    @routes.find { |route| route.matches?(req) }
  end

  def run(req, res)
    route = match(req)
    if route
      puts "#{route.controller_class}##{route.action_name}"
      route.run(req, res)
    else
      res.status = 404
    end
  end

  def resources(collection, &prc)
    controller = "#{collection.to_s.camelcase}Controller".constantize
    singular = collection.to_s.singularize

    if @base_path.empty?
      coll_path = "/#{collection}"
    else
      base_singular_id = @base_path.delete("/").singularize + "_id"
      coll_path = "/:#{base_singular_id}/#{collection}"
    end

    @base_path << coll_path
    restful_routes(@base_path, controller, collection, singular)
    prc.call if prc
    @base_path.delete(coll_path)
  end

  private

  def restful_routes(base_path, controller, collection, singular)
    get "#{base_path}", controller, :index, "#{collection}".to_sym
    get "#{base_path}/new", controller, :new, "new_#{singular}".to_sym
    post "#{base_path}", controller, :create, "#{collection}".to_sym
    get "#{base_path}/:id", controller, :show, "#{singular}".to_sym
    get "#{base_path}/:id/edit", controller, :edit, "edit_#{singular}".to_sym
    put "#{base_path}/:id", controller, :update, "#{singular}".to_sym
    delete "#{base_path}/:id", controller, :delete, "#{singular}".to_sym
  end
end
