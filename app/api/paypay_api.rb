require 'net/http'
require 'uri'

target_uri = 'https://api.sandbox.paypal.com/v1/billing/subscriptions'
uri = URI.parse(target_uri)
request = Net::HTTP::GET.new(uri)
request['Authorization'] = 'api_token'
request_options = {
  use_ssl: uri.scheme == 'https'
}

response = Net::HTTP.start(uri.hostname, uri.port, request_options) do |http|
  http.request(req)
end

response.body
