#!/usr/local/bin/ruby
#
# Sample RADIUS client
#
# This code is provided for illustrative purposes only and is placed
# in the public domain.
#
# $Id$
#
require 'radius/dictionary'
require 'radius/packet'
require 'socket'

user = 'test'
pass = 'test'
authhost = '127.0.0.1';
authport = '1812';
secret = 'h1dd3n';
dictfile = "../dictionary"

dict = Radius::Dict.new
File.open(dictfile) {
  |fn|
  dict.read(fn)
}

def bigrand()
    return([rand(65536), rand(65536), rand(65536), rand(65536), 
	     rand(65536), rand(65536), rand(65536), rand(65536)].pack("n8"))
end

ident = 170;
req = Radius::Packet.new(dict)
req.code = 'Access-Request'
req.identifier = ident
req.authenticator = bigrand()
req.set_attr('NAS-IP-Address', '127.0.0.1')
req.set_attr('User-Name', user)
req.set_password(pass, secret)
print req.to_s(nil) + "\n"
p = req.pack
print p.unpack("H*"), "\n"
print "Socket connecting\n"
sock = UDPSocket.open
sock.connect(authhost, authport)
print "Socket sending\n"
sock.send(p, 0)
rec = sock.recvfrom(65536)
resp = Radius::Packet.new(dict)
resp.unpack(rec[0])
print resp.to_s(nil)
