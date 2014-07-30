require 'socket'
require 'yaml'

config = YAML.load_file('./config/main.yml')

connection = TCPSocket.open(config['server'], config['port'])
connection.puts "USER #{config['username']} 0 * #{config['realname']}"
connection.puts "NICK #{config['nickname']}"
connection.puts "JOIN #{config['channel']}"
connection.puts "PRIVMSG #{config['channel']} :Hello world!"

def send_pong(connection, server)
  connection.puts "PONG #{server}"
end

def send_message(connection, target, message)
  connection.puts "PRIVMSG #{target} :#{message}"
end

def parse_message(message)
  unless message.nil?
    words = message.split(" ")
    parsed_message = {}

    if words[0] == "PING"
      parsed_message[:irc_command] = words[0]
      return parsed_message
    end

    parsed_message[:sender] = words[0].tr(':', '')
    parsed_message[:irc_command] = words[1]
    parsed_message[:target] = words[2]

    if /^:!(\w+)/.match words[3]
      parsed_message[:command] = words[3].tr('!', '').upcase
    end

    parsed_message
  end
end

while true do
  msg = connection.gets
  parsed_message = parse_message(msg)

  unless parsed_message.nil?
    if parsed_message[:irc_command] == "PING"
      send_pong(connection,config['server'])
      puts "PONG!"
    end
    puts parsed_message.to_s
  end

  puts msg

end