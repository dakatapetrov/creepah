Encoding.default_internal = Encoding.default_external = 'UTF-8' if RUBY_VERSION >= '1.9'
require 'sinatra/base'
require './config'

module Creepah
  module Structure
    VIEWS       = 'sinatra/views'
    CONTROLLERS = 'sinatra/controllers'
    HELPERS     = 'sinatra/helpers'
    PUBLIC      = 'sinatra/public'
  end
end


class CreepahMain < Sinatra::Base
  disable :run
  set :public_folder, Creepah::Structure::PUBLIC
  set :views, File.join(File.dirname(__FILE__), Creepah::Structure::VIEWS)

  @@server = nil

  get '/' do
    if running?
      system( "echo \"list\" > minecraft-fi" )
      file                                           = File.open( "server.log", "rb" )
      file_content                                   = file.read
      players_online, player_capacity, players_names = players_info file_content
      file.close

      erb :home, locals: { running:         true,
                           players_online:  players_online,
                           player_capacity: player_capacity,
                           players_names:   players_names,
                         }
    else
      erb :home, locals: { running: false }
    end
  end

  post '/start' do
    start_server
    sleep 3
    redirect '/'
  end

  post '/stop' do
    stop_server
    sleep 3
    redirect '/'
  end

  post '/update' do
    update_server
    sleep 3
    redirect '/'
  end
end

Dir[File.join Creepah::Structure::HELPERS, '*.rb'].each do |file|
  require "./#{file}"
end

CreepahApp = Rack::Builder.app do
  run CreepahMain
end

run CreepahApp
