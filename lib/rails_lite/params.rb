require 'uri'

class Params
  def initialize(req, route_params)
    @params = parse_www_encoded_form(req.query_string)
  end

  def [](key)
    @params[key]
  end

  def to_s
    @params.to_json
  end

  private

  def parse_www_encoded_form(www_encoded_form)
    Hash[URI::decode_www_form(www_encoded_form)]
  end

  def parse_key(key)
  end
end
