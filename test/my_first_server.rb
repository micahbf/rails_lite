require 'active_support/core_ext'
require 'webrick'

server = WEBrick::HTTPServer.new :Port => 8080
trap('INT') { server.shutdown }

server.mount_proc '/' do |request, response|
  response['Content-Type'] = 'text/text'
  response.body = request.path
end

server.start
