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
      @@server.write "list\n"
      file                                           = File.open "#{$path}server.log", 'r'
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

  post '/configure' do
    file = File.open "#{$path}server.properties", 'w'
    file.write params[:content]
    file.close
    redirect '/'
  end

  get '/configure' do
    file         = File.open "#{$path}server.properties", 'r'
    file_content = file.read
    file.close
    erb :configure, locals: { file_content: file_content }
  end
end

Dir[File.join Creepah::Structure::HELPERS, '*.rb'].each do |file|
  require "./#{file}"
end

CreepahApp = Rack::Builder.app do
  run CreepahMain
end

run CreepahApp
