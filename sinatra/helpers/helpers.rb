class CreepahMain < Sinatra::Base
  def start_server
    @@server = open("|#{$execute}", 'w')
  end

  def running?
      @@server and !@@server.closed?
  end

  def stop_server
    @@server.write "stop\n"
    @@server.close
  end

  def players_info(contents)
    players         = contents.scan(/(\d+\/\d+)/).last.first.scan(/(\d+)/)
    players_online  = players.first.first.to_i
    player_capacity = players.last.first.to_i
    if players_online > 0
      players_names   = contents.scan(/\[INFO\]\s(\w+(\,\s\w+)*)$/).
          last.first.split", "
    else
        player_names = nil
    end
    [players_online, player_capacity, players_names]
  end

  def update_server
    %x[rm minecraft_server.jar]
    %x[wget https://s3.amazonaws.com/MinecraftDownload/launcher/minecraft_server.jar]
  end
end
