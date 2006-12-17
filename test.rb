#!/usr/local/bin/ruby
# Simple test program, generates a test packet for test.pl, compare with
# Net::Radius in Perl.
# This test program is provided only for illustrative purposes and is placed
# in the public domain.
# $Id: test.rb,v 1.1 2002/07/04 15:14:34 didosevilla Exp $

require './radius/dictionary'
require './radius/packet'

dict = Radius::Dict.new
dict.read(File.new("dictionary"))
packet = Radius::Packet.new(dict)
packet.code = 'Access-Request'
packet.identifier = 1
packet.set_attr('User-Name', 'you')
packet.set_attr('NAS-IP-Address', '127.0.0.1')
packet.set_attr('NAS-Port', 1)
packet.set_attr('Service-Type', 'Framed-User')
packet.set_attr('Framed-Protocol', 'PPP')
packet.set_attr('Expiration', 1000000)
packet.set_vsattr(9, 'cisco-avpair', 'This is my VSA 1')
packet.set_vsattr(9, 'cisco-avpair', 'This is my VSA 2')
packet.set_vsattr(1, 'ibm-enum', 'value-2')
packet.set_vsattr(1, 'ibm-enum', 'value-2')
packet.set_vsattr(1, 'ibm-enum', 'value-3')
packet.authenticator = "aaaaaaaaaaaaaaaa"
packet.set_password('My-Password', 'My-Shared-Secret')
p = packet.pack
print p.unpack("H*"), "\n"
packet2 = Radius::Packet.new(dict)
# This string----| was created by test.pl
packet2.unpack(["0101009d616161616161616161616161616161610105796f751506000f424007060000000105060000000104067f0000010212bd74ad27726cd1110d87303775934bfd0606000000021a0c00000001fe06000000011a0c00000001fe06000000021a0c00000001fe06000000031a1800000009011254686973206973206d792056534120311a1800000009011254686973206973206d79205653412032"].pack("H*"))
print packet2.to_s('My-Shared-Secret') + "\n"
