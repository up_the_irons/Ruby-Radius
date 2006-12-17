#!/usr/bin/perl
# Test program in Perl using Net::Radius, to compare the results with
# our program.
# This test program is provided only for illustrative purposes and is
# placed in the public domain.
# $Id: test.pl,v 1.1 2002/07/04 15:11:01 didosevilla Exp $
#
use Net::Radius::Packet;
use Net::Radius::Dictionary;

my $dict = new Net::Radius::Dictionary "./dictionary" 
  or die "Cannot read or parse dictionary: $!\n";

my $packet = new Net::Radius::Packet $dict;

$packet->set_code('Access-Request');
$packet->set_identifier(1);
$packet->set_attr('User-Name', 'you');
$packet->set_attr('NAS-IP-Address', '127.0.0.1');
$packet->set_attr('NAS-Port', 1);
$packet->set_attr('Expiration', 1000000);
$packet->set_attr('Service-Type' => 'Framed-User');
$packet->set_attr('Framed-Protocol' => 'PPP');
$packet->set_vsattr(9, 'cisco-avpair', 'This is my VSA 1');
$packet->set_vsattr(9, 'cisco-avpair', 'This is my VSA 2');
$packet->set_vsattr(1, 'ibm-enum', 'value-1');
$packet->set_vsattr(1, 'ibm-enum', 'value-2');
$packet->set_vsattr(1, 'ibm-enum', 'value-3');
$packet->set_authenticator("aaaaaaaaaaaaaaaa");
$packet->set_password('My-Password', 'My-Shared-Secret');
my $p = $packet->pack;
print unpack("H*", $p) . "\n";

my $packet2 = new Net::Radius::Packet $dict;
# this string----------------| was generated from test.rb
$packet2->unpack(pack("H*", "0101009d616161616161616161616161616161610212bd74ad27726cd1110d87303775934bfd0606000000020105796f750706000000010506000000011506000f424004067f0000011a0c00000001fe06000000021a0c00000001fe06000000021a0c00000001fe06000000031a1800000009011254686973206973206d792056534120311a1800000009011254686973206973206d79205653412032"));
$packet2->dump;
#print "RAD-Code = " . $packet2->code . "\n";
#print "RAD-Identifier = " . $packet2->identifier . "\n";
#print "RAD-Authenticator = " . $packet2->authenticator . "\n";
#foreach $attr ($packet2->attributes) {
#  $val = ($attr eq "User-Password") ? $packet2->password("My-Shared-Secret") :
#    $packet2->attr($attr);
#  print "$attr = $val\n";
#}
