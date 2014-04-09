require 'socket'
require 'openssl'

begin
  port = (ARGV[0] || 4443).to_i
  socket = TCPSocket.new('localhost', port)
  ssl = OpenSSL::SSL::SSLSocket.new(socket)
  ssl.sync_close = true
  ssl.connect
rescue OpenSSL::SSL::SSLError
  # expected
end
