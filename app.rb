# encoding: UTF-8
require 'bundler/setup'
require 'sinatra'
require 'steam-condenser'
require 'data_mapper'
require 'json'

class Index < Sinatra::Base
  helpers do
    def create_user(name, steam_id, webapi) 
      User.create(
        name: name,
        dota_id: steam_id - 76561197960265728
      )

    end
  end

  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db/dota_per.db")
  configure :test do
    DataMapper.setup(:default, "sqlite::memory:")
  end

  class User
    include DataMapper::Resource

    property :id,      Serial
    property :name,    String
    property :dota_id, String, :unique => true
  end

  class Match
    include DataMapper::Resource

    property :id,       Serial
    property :player,   String
    property :won,      Boolean
    property :date,     DateTime
    property :match_id, String
  end


  file = File.new('key', 'r')
  key = file.gets
  file.close

  WebApi.api_key = key

  get '/stylesheets/style.css' do
    content_type 'text/css', :charset => 'utf-8'
    sass :style
  end

  def match_won?(match_id, dota_id)
    fetch = WebApi.get(:json, 'IDOTA2Match_570', 'GetMatchDetails', 1, {:match_id => match_id})
    result = JSON.parse(fetch, opts = {symbolize_names: true})[:result]
    # Magic: 1 XOR 2
    # 1 - did radiance win
    # 2 - was player in dire
    # 2 - (player_slot & 128 ) != 0
    radiant_win = result[:rediant_win] == 1
    player_slot = result[:players].select { |player| player[:match_id] == dota_id }.first
    player_dire = (player_slot & 128) != 0
    return [radiant_win,player_dire]
  end

  get '/?' do
    #got = WebApi.get(:json, 'IDOTA2Match_570', 'GetMatchHistory', 1, {:account_id => 50958904})
    #data = JSON.parse(got, opts = {symbolize_names: true})
    #matches = data[:result][:matches].collect { |x| x[:match_id] }
    #got = WebApi.get(:json, 'IDOTA2Match_570', 'GetMatchDetails', 1, {:match_id => '143550516'})
    #data = JSON.parse(got, opts = {symbolize_names: true})
    erb :index, locals: {text: match_won?('143005390', '50958904').to_s}
  end
end

Index.run!
