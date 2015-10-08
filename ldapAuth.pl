#!/usr/local/bin/env perl
use warnings;
use strict;
use Net::LDAP;
# Upon review, not even sure I'm using this module.
# I just have it in here cause it was an example I saw elsewhere.
use Net::LDAP::Util qw(ldap_error_text
                       ldap_error_name
                       ldap_error_desc
                      );

# May want to user Get::Opt
# or Term::Readline to take a password
# depending on your application.
my $userName = $ARGV[0];
my $password = $ARGV[1];
my $mesg;

#Create the LDAP object for connecting.
my $LDAPServerAddress =  'ldap.server.com';
my $LDAPPort ='389';

my $ldap = Net::LDAP->new($LDAPServerAddress, port => $LDAPPort) or
   die "Can't connect to $LDAPServerAddress via LDAP";

#Anonymous Bind to LDAP
$mesg = $ldap->bind;
if ($mesg->code) {
    print "Failed to connect to LDAP server using anonymous bind!";
    die $mesg->error;
}

#Search for the user, save their DN
my $search = $ldap->search(
    base   => 'DC=corp,DC=global,DC=company,DC=com',
    scope  => 'sub',
    filter => "(&(sAMAccountName=$userName))",
    attrs  => ['dn']
);
die "Username not found" if not $search->count;

my $userDN = $search->entry->dn;

#Attempt to bind using that DN and password
my $userConnMesg = $ldap->bind($userDN, password => $password);
if ($userConnMesg->code) {
    print "Failed to authenticate user!\n";
    die $userConnMesg->error;
} else {
    print "Successfully authenticated user!\n";
    $ldap->unbind;
}

1;
