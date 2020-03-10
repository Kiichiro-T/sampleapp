require 'net/http'
require 'uri'
require 'json'
require 'dotenv'

class ApiToken
  class << self
    def make_uri
      URI.parse('https://api.sandbox.paypal.com/v1/oauth2/token')
    end

    def set_environment
      Dotenv.load
      { username: ENV['PAYPAL_CLIENT_ID'], password: ENV['PAYPAL_CLIENT_SECRET'] }
    end

    def set_http
      uri = make_uri
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http
    end

    def set_request
      header = {
        'Accept' => 'application/json',
        'Accept-Language' => 'en_US'
      }
      params = { 'grant_type' => 'client_credentials' }
      uri = make_uri

      req = Net::HTTP::Post.new(uri.path)
      req.initialize_http_header(header)
      env = set_environment
      req.basic_auth(env[:username], env[:password])
      req.set_form_data(params)
      req
    end

    def response_body
      http = set_http
      req = set_request
      res = http.request(req)
      res.body
    end

    def get_hash
      JSON.parse(response_body, symbolize_names: true)
    end

    def access_token
      hash = get_hash
      hash[:access_token]
    end
  end
end
