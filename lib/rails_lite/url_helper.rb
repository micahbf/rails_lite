module UrlHelper
  def self.register(route_name, path)
    define_method(route_name) do { path }
  end
end