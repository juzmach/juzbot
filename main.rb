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

  if message.include? "PING"
    return "PING"
  elsif message.include? "PRIVMSG"
    words = message.split(" ")
    parsed_message = {sender: words[0],
                      message_type: words[1],
                      target: words[2]}

    if /^:!(\w+)/.match words[3]
      parsed_message[:command] = words[3].tr('!','').upcase
    end
      parsed_message
  end
end

while true do
  msg = connection.gets
  parsed_message = parse_message(msg)

  if parsed_message == "PING"
    send_pong(connection, config['server'])
    puts "PONG message sent"
  else
    unless parsed_message.nil?
      puts parsed_message.to_s
    end
  end

  puts msg

end