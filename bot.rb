require 'socket'
require 'yaml'

class Bot

  def initialize
    config = YAML.load_file('./config/bot.yml')

    @server = config['server']
    @port = config['port']
    @username = config['username']
    @realname = config['realname']
    @nickname = config['nickname']
    @channel = config['channel']
    @connection = nil
    @running = false
  end

  def connect
    @running = true
    connection = TCPSocket.open(@server, @port)
    connection.puts "USER #{@username} 0 * #{@realname}"
    connection.puts "NICK #{@nickname}"
    connection.puts "JOIN #{@channel}"
    #returns
    connection
  end

  def send_pong
    @connection.puts "PONG #{@server}"
  end

  def send_message(target, message)
    @connection.puts "PRIVMSG #{target} :#{message}"
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
        parsed_message[:command] = words[3].tr(':!', '').upcase
      end

      parsed_message
    end
  end

  def listen_and_respond(msg)
    parsed_message = parse_message(msg)

    unless parsed_message.nil?
      if parsed_message[:irc_command] == "PING"
        send_pong
        puts "PONG!"
      elsif parsed_message[:command] == "HELLO"
        send_message(@channel, "Hello!")
      end

      # Uncomment below to check the hash
      # puts parsed_message.to_s
    end

    puts msg
  end

  def run
    @connection = connect

      while @running == true do
        listen_and_respond(@connection.gets)
      end

    @connection.close

  end

  def stop
    @running = false
  end

end