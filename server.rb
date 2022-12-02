# frozen_string_literal: true

require 'sinatra'
require 'sinatra/cookies'
require 'shopify_api'
require 'pry'
require 'json'

before do
  content_type :json

  shop_name = ENV['SHOPIFY_SHOP']
  @shop = "#{shop_name}.myshopify.com"

  setup_shopify
end

get '/' do
  shop = @shop
  is_online = false
  redirect_path = '/oauth/shopify/callback' # Need to be an allowed redirection in Shopify Partner Panel

  auth_response = ShopifyAPI::Auth::Oauth.begin_auth(shop:, is_online:, redirect_path:)

  cookies[auth_response[:cookie].name] = auth_response[:cookie].value

  redirect auth_response[:auth_route]
end

get '/oauth/shopify/callback' do
  begin
    code, shop, timestamp, state, host, hmac = params.values_at(:code, :shop, :timestamp, :state, :host, :hmac)

    auth_result = ShopifyAPI::Auth::Oauth.validate_auth_callback(
      cookies: cookies.to_h,
      auth_query: ShopifyAPI::Auth::Oauth::AuthQuery.new(code:, shop:, timestamp:, state:, host:, hmac:)
    )

    redirect '/shop'
  rescue => e
    {
      cookies: cookies.to_h,
      params: params,
      message: e.message
    }.to_json
  end
end

get '/shop' do
  session = ShopifyAPI::Utils::SessionUtils.load_offline_session(shop: @shop)
  client = ShopifyAPI::Clients::Rest::Admin.new(session: session)

  response = client.get(path: "shop")

  response.body.to_json
end


def setup_shopify
  ShopifyAPI::Context.setup(
    api_key: ENV['SHOPIFY_API_KEY'],
    api_secret_key: ENV['SHOPIFY_API_SECRET_KEY'],
    host: "#{request.scheme}://#{request.host}:#{request.port}",
    scope: ENV['SHOPIFY_SCOPE'],
    session_storage: ShopifyAPI::Auth::FileSessionStorage.new,
    is_embedded: false,
    api_version: '2022-01',
    is_private: false
  )
end
