# encoding: BINARY
require 'socket'
require 'timeout'
require 'openssl'

require_relative 'shared'

port = (ARGV[0] || 4443).to_i

server = TCPServer.new("localhost", port)

loop do
  client = server.accept
  
  begin 
    read_record(client)
    client.write(SERVER_HELLO)
    puts "Server Hello sent. Sending Heartbeat now."
    client.write(PAYLOAD)

    evaluate_heartbeat(client)
  ensure
    client.close
  end
end
