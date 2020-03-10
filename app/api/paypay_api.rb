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
  Dotenv.load
  header = {
    'Accept' => 'application/json',
    'Authorization' => 'A21AAGUTGjeh9dlD_sOneb3UehnkiqHMu-oUm6LXH9aFekWM4jkNUxd0QCioHzIm1pemoTD8oy_9Zu64yWX8YcpH8-nOcc04Q',
    'PayPal-Request-Id' => ENV['PAYPAL_REQUEST_ID'],
    'Prefer' => 'return=representation',
    'Content-Type' => 'application/json'
  }
  params = {
    'plan_id' => ENV['PLAN_ID'],
    'start_time' => "#{Time.current}.to_s",
    'subscriber' => {
      'name' => {
        'given_name' => '太郎',
        'surname' => 'テスト'
      },
      'email_address' => 'sb-xirpe730311@personal.example.com'
    },
    'application_context' => {
      'locale' => 'ja-JP',
      'shipping_preference' => 'NO_SHIPPING',
      'user_action' => 'CONTINUE',
      'return_url' => 'localhost:3000/groups/new',
      'cancel_url' => 'localhost:3000/groups/new'
    }
  }
  uri = make_uri

  req = Net::HTTP::Post.new(uri.path)
  req.initialize_http_header(header)
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