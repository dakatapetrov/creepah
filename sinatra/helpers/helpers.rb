class CreepahMain < Sinatra::Base
    def start_server
      system( "mkfifo minecraft-fi" )
      Thread.new do
        system( "cat > minecraft-fi" )
      end
      @@cat_pid = $?.pid
      @@server = Thread.new do
        system( "cat minecraft-fi | java -Xms1G -Xmx1G -jar minecraft_server.jar nogui" )
      end
    end

    def running?
        @@server and @@server.alive?
    end

    def stop_server
      system( "echo \"stop\" > minecraft-fi" )
      system( "kill #{@@cat_pid}" )
      @@server = nil
    end

    def players_info(contents)
      players         = contents.scan( /(\d+\/\d+)/ ).last.first.scan( /(\d+)/ )
      players_online  = players.first.first.to_i
      player_capacity = players.last.first.to_i
      if players_online > 0
        players_names   = contents.scan( /\[INFO\]\s(\w+(\,\s\w+)*)$/ ).
            last.first.split", "
      else
          player_names = nil
      end
      [players_online, player_capacity, players_names]
    end

    def update_server
      system( "rm minecraft_server.jar" )
      system( "wget https://s3.amazonaws.com/MinecraftDownload/launcher/minecraft_server.jar" )
    end
end
