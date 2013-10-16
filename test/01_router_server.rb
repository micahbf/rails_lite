require 'active_support/core_ext'
require 'json'
require 'webrick'
require 'rails_lite'

server = WEBrick::HTTPServer.new :Port => 8080
trap('INT') { server.shutdown }

class StatusController < ControllerBase
  def index
    statuses = ["s1", "s2", "s3"]

    render_content(statuses.to_json, "text/json")
  end

  def show
    render_content("status ##{params[:id]}", "text/text")
  end
end

class UserController < ControllerBase
  def index
    users = ["u1", "u2", "u3"]

    render_content(users.to_json, "text/json")
  end
end

server.mount_proc '/' do |req, res|
  router = Router.new
  router.draw do
    get "/statuses", StatusController, :index
    get "/users", UserController, :index
    get "/statuses/:id", StatusController, :show
  end

  route = router.run(req, res)
end

server.start
