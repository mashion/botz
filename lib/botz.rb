require 'eventmachine'
require 'botz/version'

module Botz
  class ChannelLogger < EventMachine::Connection
    include EventMachine::Protocols::LineText2

    def self.connect(server, port, nick, channel)
      EM.connect(server, port.to_i, self, :server => server, :port => port, :nick => nick, :channel => channel)
    end

    def initialize(options)
      super
      @server  = options[:server]
      @port    = options[:port]
      @nick    = options[:nick]
      @channel = options[:channel]

      @incoming_data_handlers = {
        /^PING (.*)/i => :ping_response,
        /:([^!]+)![^ ]+ PRIVMSG #{@channel} :#{@nick}: (.*)/i => :personal_response
      }
    end

    # Gets called after EM connects
    def post_init
      puts "Connected"
      execute "USER #@nick botz botz :Botz"
      execute "NICK #@nick"
      execute "JOIN #@channel"
    end

    def receive_line(line)
      puts "Got line: '#{line}'"
      meth, captures = incoming_data_handler_for(line)
      execute(send(meth, *captures)) if meth
    end

    def say(msg)
      execute to_channel(msg)
    end

    def ping_response(msg)
      "PONG #{msg}"
    end

    def personal_response(from, msg)
      to_channel("#{from}: I didn't mean you!")
    end

    def incoming_data_handler_for(line)
      regex, meth = @incoming_data_handlers.detect { |regex, meth| line =~ regex }
      return meth, Regexp.last_match.captures if Regexp.last_match
    end
    private :incoming_data_handler_for

    def to_channel(msg)
      "PRIVMSG #@channel :#{msg}"
    end
    private :to_channel

    def execute(data)
      puts "sending '#{data}'"
      send_data "#{data}\n"
    end
    private :execute

    # TODO (trotter): Move reconnect and unbind into a separate process
    #                 once we have an application container and things.
    def reconnect!
      EM.add_timer(3) do
        reconnect(@server, @port)
        post_init
      end
    end

    # EM will call this when the connection dies
    def unbind
      reconnect!
    end
  end
end

EM.run {
  cl = Botz::ChannelLogger.connect("irc.freenode.net", 6667, "thebotztime", ARGV[0])
  cl.say("Say hi to me")
}
