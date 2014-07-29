require 'socket'
require 'yaml'

config = YAML.load_file('./config/main.yml')

connection = TCPSocket.open(config['server'], config['port'])
connection.puts "USER #{config['username']} 0 * #{config['realname']}"
connection.puts "NICK #{config['nickname']}"
connection.puts "JOIN #{config['channel']}"
connection.puts "PRIVMSG #{config['channel']} :Hello world!"

while true do
  msg = connection.gets
  puts msg
end