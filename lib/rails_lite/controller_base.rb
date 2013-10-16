require 'erb'
require_relative 'params'
require_relative 'session'

class ControllerBase
  attr_reader :params

  def initialize(req, res, router_params)
    @request = req
    @response = res
    @params = Params.new(req, router_params)
  end

  def session
    @session ||= Session.new(@request)
  end

  def already_rendered?
    @already_built_response || false
  end

  def redirect_to(url)
    @response.status = 302
    @response['Location'] = url
    session.store_session(@response)
    @already_built_response = true
  end

  def render_content(content, type)
    @response['Content-Type'] = type
    @response.body = content
    session.store_session(@response)
    @already_built_response = true
  end

  def render(template_name)
    file_path = "views/#{self.class.name.underscore}/#{template_name}.html.erb"
    template = ERB.new(File.read(file_path))
    rendered = template.result(binding)
    render_content(rendered, 'text/html')
  end

  def invoke_action(action_name)
    self.send(action_name)
    render(action_name) unless already_rendered?
  end
end
