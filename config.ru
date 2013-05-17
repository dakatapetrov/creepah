nternal = Encoding.default_external = 'UTF-8' if RUBY_VERSION >= '1.9'
require 'sinatra/base'

class MinecraftMain < Sinatra::Base
  disable :run
  @@server = nil

  get '/' do
    is_running = @@server and @@server.alive?
    if is_running
      system( "echo \"list\" > minecraft-fi" )
      file = File.open( "server.log", "rb" )
      contents = file.read
      players_log = contents.scan( /(\d+\/\d+)/ ).last.first.scan( /(\d+)/ )
      players_online = players_log.first.first
      player_capacity = players_log.last.first
      if players_online.to_i > 0
          player_names = contents.scan( /\[INFO\]\s(\w+(\,\s\w+)*)$/ ).last.first.split", "
      else
          player_names = nil
      end
      file.close

      erb :home, locals: { is_running: is_running,
                           players_online: players_online,
                           player_capacity: player_capacity,
                           player_names: player_names }
    else
      erb :home, locals: { is_running: is_running }
    end
  end

  post '/start' do
    system( "mkfifo minecraft-fi" )
    Thread.new do
      system( "cat > minecraft-fi" )
    end
    @@cat_pid = $?.pid
    @@server = Thread.new do
      system( "cat minecraft-fi | java -Xms1G -Xmx1G -jar minecraft_server.jar nogui" )
    end
    sleep 3

    redirect '/'
  end

  post '/stop' do
    system( "echo \"stop\" > minecraft-fi" )
    system( "kill #{@@cat_pid}" )
    @@server = nil

    sleep 3
    redirect '/'
  end

  post '/update' do
    system( "rm minecraft_server.jar" )
    system( "wget https://s3.amazonaws.com/MinecraftDownload/launcher/minecraft_server.jar" )

    sleep 3
    redirect '/'
  end
end

MinecraftApp = Rack::Builder.app do
  run MinecraftMain
end

run MinecraftApp
