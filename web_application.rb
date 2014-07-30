require 'sinatra'
require './bot.rb'



get '/' do
  erb :index
end

get '/start_bot' do
  @bot = Bot.new
  @bot.run
end

get '/stop_bot' do
  @bot.stop
end