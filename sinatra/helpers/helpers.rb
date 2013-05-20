class CreepahMain < Sinatra::Base
  attr_reader :server

  def start_server
    @server = open "|cd #{Creepah::Config::PATH};
                     #{Creepah::Config::EXECUTE}",
                    'w'
  end

  def running?
      @server && !@server.closed?
  end

  def stop_server
    @server.write "stop\n"
    @server.close
  end

  def players_info(contents)
    players         = contents.scan(/(\d+\/\d+)/).last.first.scan(/(\d+)/)
    players_online  = players.first.first.to_i
    player_capacity = players.last.first.to_i
    if players_online > 0
      players_names   = contents.scan(/\[INFO\]\s(\w+(\,\s\w+)*)$/)
                          .last.first.split", "
    else
        players_names = nil
    end
    [players_online, player_capacity, players_names]
  end

  def update_server
    `rm #{Creepah::Config::PATH}minecraft_server.jar`
    `cd #{Creepah::Config::PATH}; wget
     https://s3.amazonaws.com/MinecraftDownload/launcher/minecraft_server.jar`
  end
end
