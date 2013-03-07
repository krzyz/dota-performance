# encoding: UTF-8
require 'bundler/setup'
require 'sinatra'
require 'steam-condenser'
require 'data_mapper'
require 'json'

class Index < Sinatra::Base
  helpers do

  end

  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db/dota_per.db")
  configure :test do
    DataMapper.setup(:default, "sqlite::memory:")
  end

  get '/stylesheets/style.css' do
    content_type 'text/css', :charset => 'utf-8'
    sass :style
  end

  get '/?' do
    erb :index
  end
end
