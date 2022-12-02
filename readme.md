# Shopify Oauth Ruby

This is a simple Sinatra app to test Shopify Oauth for app created through [Shopify Partner](https://github.com/Shopify).

# Usage

Create `env` file by running `cp .env.example .env` and edit it with your config.

Install dependecies through `bundle install`

Run server with `dotenv ruy server.rb`

Run ngrok tunnel with `ngrok http 4567`

Navigate the ngrok generated url.

# Requirements
* Ruby 3.1.3
* [Ngrok Account](https://ngrok.com/)
* Shopify Partner App
