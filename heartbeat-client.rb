require 'socket'
require 'openssl'

begin
  socket = TCPSocket.new('localhost', 4443)
  ssl = OpenSSL::SSL::SSLSocket.new(socket)
  ssl.sync_close = true
  ssl.connect
rescue OpenSSL::SSL::SSLError
  # expected
end
