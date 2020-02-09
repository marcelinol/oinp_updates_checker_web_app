require "sinatra"
require "sinatra/reloader" if development?
require_relative "lib/user_subscriber"

get "/" do
  erb :"index.html"
end

post "/register" do
  UserSubscriber.new(params[:email]).subscribe!
  "SUCCESS"
rescue StandardError => e
  e.message
end
