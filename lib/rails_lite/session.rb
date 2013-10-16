require 'json'
require 'webrick'

class Session
  def initialize(req)
    cookie = req.cookies.find { |c| c.name == '_rails_lite_app' }
    if cookie
      @session = JSON.parse(cookie.value)
    else
      @session = {}
    end
  end

  def [](key)
    @session[key]
  end

  def []=(key, val)
    @session[key] = val
  end

  def store_session(res)
    cookie = WEBrick::Cookie.new('_rails_lite_app', @session.to_json)
    res.cookies << cookie
  end
end
