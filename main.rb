require 'socket'
require 'yaml'

config = YAML.load_file('./config/main.yml')

connection = TCPSocket.open(config['server'], config['port'])
connection.puts "USER #{config['username']} 0 * #{config['realname']}"
connection.puts "NICK #{config['nickname']}"
connection.puts "JOIN #{config['channel']}"
connection.puts "PRIVMSG #{config['channel']} :Hello world!"

def sendPong(connection, server)
  connection.puts "PONG #{server}"
end

def sendMessage(connection, target, message)
  connection.puts "PRIVMSG #{target} :#{message}"
end

def parseMessage(message)

  if message.include? "PING"
    return "PING"
  else
    words = message.split(" ")
    sender = words[0]
    ircMessageType = words[1]
    target = words[2]

    if /^:!(\w+)/.match words[3]
      return words[3].tr('!','').upcase
    end

  end

end

while true do
  msg = connection.gets

  msgType = parseMessage(msg)

  if msgType == "PING"
    sendPong(connection, config['server'])
    puts "PONG message sent"
  else
    puts msgType
  end

  puts msg

end