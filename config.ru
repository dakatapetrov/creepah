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
      file             = File.open "#{Creepah::Config::PATH}server.log", 'r'
      file_content     = file.read
      players_online,
      player_capacity,
      players_names    = players_info file_content
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
    boolean = [
               :spawn_npcs,   :white_list,  :spawn_animals, :snooper_enabled,
               :online_mode,  :pvp,         :allow_nether,  :enable_query,
               :allow_flight, :enable_rcon, :force_gamemode, :spawn_monsters,
               :generate_structures
              ]
    strings = [
               :generator_settings, :level_name, :server_port,      :level_type,
               :level_seed,         :server_ip,  :max_build_height, :texture_pack,
               :difficulty,         :gamemode,   :max_players,      :view_distance,
               :spawn_protection,   :motd
             ]
    content = strings.reduce("") do |s, k|
        s.concat k.to_s.gsub("_", "-").concat "=".concat  params[k].concat "\n"
    end
    content2 = boolean.reduce("") do |s, k|
        if params[k]
            s.concat k.to_s.gsub("_", "-").concat "=true\n"
        else
            s.concat k.to_s.gsub("_", "-").concat "=false\n"
        end
    end
    content = content.concat content2
    file = File.open "#{Creepah::Config::PATH}server.properties", 'w'
    file.write content.chomp
    file.close
    redirect '/'
  end

  get '/configure' do
    file         = File.open "#{Creepah::Config::PATH}server.properties", 'r'
    file_content = file.read.split("\n").map { |line| line.split("=") }
     settings_values = file_content.reduce({}) do |s, m|
         s[m[0].gsub("-", "_").to_sym] = m[1]
         s
     end
    file.close
    erb :configure, locals: { file_content: file_content,
                              settings_values: settings_values,
                            }
  end

  post '/edit' do
    file = File.open "#{Creepah::Config::PATH}server.properties", 'w'
    file.write params[:content].gsub /\r/, ""
    file.close
    redirect '/'
  end

  get '/edit' do
    file         = File.open "#{Creepah::Config::PATH}server.properties", 'r'
    file_content = file.read
    file.close
    erb :edit, locals: { file_content: file_content }
  end
end

Dir[File.join Creepah::Structure::HELPERS, '*.rb'].each do |file|
  require "./#{file}"
end

CreepahApp = Rack::Builder.app do
  run CreepahMain
end

run CreepahApp
