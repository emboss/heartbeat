# encoding: BINARY
require 'socket'
require 'timeout'

require_relative 'shared'

def read_until_server_hello_done(sock)
  loop do
    record = read_record(sock)
    break if record.value == SERVER_HELLO_DONE
  end
end

server = ARGV[0]
port = ARGV[1] ? ARGV[1].to_i : 443
raise "Usage: ruby heartbeat.rb <server>" unless server

sock = begin
  Timeout.timeout(3) { TCPSocket.open(server, port) }
rescue Timeout::Error
  raise "Couldn't connect to #{server}:#{port}"
end

sock.write(CLIENT_HELLO)

begin
  read_until_server_hello_done(sock)
rescue Timeout::Error
  raise "Couldn't establish TLS connection."
end

sock.write(PAYLOAD)

evaluate_heartbeat(sock)

