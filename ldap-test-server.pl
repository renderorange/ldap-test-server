#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long ();
use Pod::Usage   ();
use Net::LDAP::Server::Test;
use Net::LDAP;

my %opt = (
    port => 6570,
);
Getopt::Long::GetOptions(
    \%opt,
    'port=i',
    'debug',
    'help',
) || Pod::Usage::pod2usage(1);

Pod::Usage::pod2usage(0) if ($opt{help});

if ($opt{debug}) {
    print "[info] setting ldap debug\n";
    $ENV{LDAP_DEBUG} = 1;
}

print "[info] spawning test LDAP server on port " . $opt{port} . "\n";
my $server = Net::LDAP::Server::Test->new( $opt{port}, auto_schema => 1 );

my $client = Net::LDAP->new( 'localhost:' . $opt{port} );
my $ret    = $client->bind();
if ( $ret->code ) {
    die "[error] ldap client: " . $ret->error . "\n";
}

my $username   = 'testldapuser';
my $email      = "$username\@example.com";
my $name       = 'Test LDAP User';
my $nick       = 'aoldude1982';
my $password   = 'password';
my $base       = 'dc=example,dc=com';
my $users_dn   = "ou=users,$base";
my $group_name = 'test ldap group';
my $group_dn   = "cn=$group_name,ou=groups,$base";
my $dn         = "uid=$username,$users_dn";

my $entry      = {
    cn           => $name,
    mail         => $email,
    uid          => $username,
    objectClass  => 'User',
    userPassword => $password,
    nick         => $nick,
};

print "[info] creating test ldap user: $username - $email\n";

$ret = $client->add( $dn, attr => [%$entry] );
if ( $ret->code ) {
    die "[error] ldap client: " . $ret->error . "\n";
}

print "[info] creating test ldap group: $group_name\n";

$ret = $client->add(
    $group_dn,
    attr => [
        cn          => $group_name,
        memberDN    => [ $dn ],
        objectClass => 'Group',
    ],
);
if ( $ret->code ) {
    die "[error] ldap client: " . $ret->error . "\n";
}

my $exit = 0;
$SIG{INT} = sub { $exit = 1 };

print "ctrl+c to exit\n";

while (1) {
    if ($exit) {
        print "\n[info] unbinding LDAP client and shutting down server\n";
        $client->unbind();
        print "[info] exiting\n";
        exit;
    };
}

__END__

=pod

=head1 NAME

ldap-test-server.pl - runs a local test LDAP server

=head1 DESCRIPTION

C<ldap-test-server.pl> is a perl script to run a local test LDAP server for development purposes.

LDAP users and groups are defined and added on spinup.  LDAP data does not persist shutdown.

=head1 SYNOPSIS

 ldap-test-server.pl [--port <port number>] [--debug]
                     [--help]

=head1 OPTIONS

=over

=item --port

port to bind the LDAP server to; defaults to 6570

=item --debug

enable debug output from C<Net::LDAP::Server::Test>

=item --help

print this dialogue

=back

=head1 DEPENDENCIES

=over

=item L<Getopt::Long>

=item L<Pod::Usage>

=item L<Net::LDAP::Server::Test>

=item L<Net::LDAP>

=back

=cut
