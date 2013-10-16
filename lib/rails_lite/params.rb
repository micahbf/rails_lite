require 'uri'

class Params
  def initialize(req, route_params)
    @params = route_params
    @params.merge!(parse_www_encoded_form(req.query_string))
    @params.merge!(parse_www_encoded_form(req.body))
  end

  def [](key)
    @params[key]
  end

  def to_s
    @params.to_json
  end

  private

  def parse_www_encoded_form(www_encoded_form)
    if www_encoded_form
      flat_hash = Hash[URI::decode_www_form(www_encoded_form)]
      form_hash = {}
      flat_hash.map do |key, value| 
        keys = parse_key(key)
        last = form_hash
        keys[0...-1].each do |hkey|
          last[hkey] ||= {}
          last = last[hkey]
        end
        last[keys.last] = value
      end
      form_hash
    else
      return {}
    end
  end

  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end
