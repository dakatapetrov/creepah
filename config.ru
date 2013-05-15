nternal = Encoding.default_external = 'UTF-8' if RUBY_VERSION >= '1.9'
require 'sinatra/base'

class MinecraftMain < Sinatra::Base
  disable :run

  get '/' do
    is_running = system( "if ps -el | grep -e java; then true; else false; fi" )

    erb :home, locals: { is_running: is_running }
  end

  post '/start' do
      system( "mkfifo minecraft-fi" )
    start = Thread.new do
      system( "cat minecraft-fi | java -Xms1G -Xmx1G -jar minecraft_server.jar nogui" )
    end
    sleep 3

    redirect '/'
  end

  post '/stop' do
    system( "echo \"stop\" > minecraft-fi" )
    # if $?.exitstatus.zero?
    #     erb :status, locals: { success: "Server successfully stopped" }
    # else
    #     erb :status, locals: { failure: "Something went wrong" }
    # end

    sleep 3
    redirect '/'
  end

  post '/update' do
    system( "rm minecraft_server.jar" )
    # if $?.exitstatus.zero? or not system( "test -f minecraft_server.jar" )
       system( "wget https://s3.amazonaws.com/MinecraftDownload/launcher/minecraft_server.jar" )
    #   if $?.exitstatus.zero?
    #       erb :status, locals: { success: "Server updated succcessfully" }
    #   else
    #       erb :status, locals: { failure: "Could not download neccessary files" }
    #   end
    # else
    #     erb :status, locals: { failure: "Could not delete old files." }
    # end

    sleep 3
    redirect '/'
  end
end

MinecraftApp = Rack::Builder.app do
  run MinecraftMain
end

run MinecraftApp
