require 'net/http'
require 'uri'
require 'json'
require 'dotenv'

def make_uri
  URI.parse('https://api.sandbox.paypal.com/v1/billing/subscriptions')
end

def set_http
  uri = make_uri
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http
end

def set_request
  # require 'byebug'
  # byebug
  Dotenv.load
  header = {
    'Accept' => 'application/json',
    'Content-Type' => 'application/json',
    'Authorization' => 'Bearer A21AAEdcCHqiGhPYdWUcAJJjMdsZn3kTdBlirT-twWf8aTiLiez9fG68OFM7bU-A7ekPKMqLZoGl_MsJii_zpm-irK3k7fe5A',
    'PayPal-Request-Id' => ENV['PAYPAL_REQUEST_ID'],
    'Prefer' => 'return=representation'
  }
  params = {
    'plan_id' => 'P-6C205614FV432243SLZQOWVQ',
    'start_time' => "2020-03-15T06:00:00Z",
    'subscriber' => {
      'name' => {
        'given_name' => 'John',
        'surname' => 'Doe'
      },
      'email_address' => 'customer@example.com'
    },
    'application_context' => {
      'locale' => 'ja-JP',
      'shipping_preference' => 'NO_SHIPPING',
      'user_action' => 'CONTINUE',
      'return_url' => 'https://example.com/returnUrl',
      'cancel_url' => 'https://example.com/cancelUrl'
    }
  }.to_json
  uri = make_uri

  req = Net::HTTP::Post.new(uri.path)
  req.body = params
  req.initialize_http_header(header) # 順番を逆にするとContent-Typeが変わってしまう
  req
end

def response_body
  http = set_http
  req = set_request
  res = http.request(req)
  puts res.code
  res.body
end

def get_hash
  JSON.parse(response_body, symbolize_names: true)
end

puts get_hash
