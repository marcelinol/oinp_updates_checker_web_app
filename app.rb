require "sinatra"
require "sinatra/reloader" if development?
require_relative "lib/user_subscriber"
require_relative "lib/logs_fetcher"

get "/" do
  @logs = LogsFetcher.new.logs
  erb :"index.html"
end

post "/register" do
  UserSubscriber.new(params[:email]).subscribe!
  "SUCCESS"
rescue StandardError => e
  e.message
end
