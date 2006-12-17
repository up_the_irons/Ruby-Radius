#!/usr/local/bin/ruby
#
# Sample RADIUS client using the new Radius::Auth class
#
# This code is provided for illustrative purposes only and is placed
# in the public domain.
#
# $Id: rclient.rb,v 1.1 2002/07/04 15:32:51 didosevilla Exp $
#
require 'radius/auth'

auth = Radius::Auth.new('../dictionary', '127.0.0.1', 5)
secret = 'h1dd3n'
print "login: "
user = $stdin.readline
user.chomp!
print "Password: "
pass = $stdin.readline
pass.chomp!
if (auth.check_passwd(user, pass, secret, '127.0.0.1'))
  print "Authentication successful.\n"
else
  print "Authentication failed.\n"
end
