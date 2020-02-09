require "sinatra"
require "sinatra/reloader" if development?
require_relative "lib/user_subscriber"
require_relative "lib/logs_fetcher"

enable :sessions

get "/" do
  @message = session.delete(:message)
  @logs = LogsFetcher.new.logs
  erb :"index.html"
end

post "/register" do
  UserSubscriber.new(params[:email]).subscribe!
  session[:message] = {
    status: "success",
    content: "Email #{params[:email]} successfully registered."
  }
  redirect("/")
rescue StandardError, ArgumentError => e
  session[:message] = {
    status: "failure",
    content: e.message
  }
  redirect("/")
end
