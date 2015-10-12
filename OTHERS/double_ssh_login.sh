#!/usr/bin/expect

set login "nisal"
set addr "address1"
set addr2 "address2"
set pw "password"

spawn ssh $login@$addr
expect "$login@$addr\'s password:"
send "$pw\r"
expect "$login@host:"
send "ssh $addr2\r"
expect "$login@$addr\'s password:"
send "$pw\r"
interact
