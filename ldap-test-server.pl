#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long ();
use Pod::Usage   ();
use Net::LDAP::Server::Test;
use Net::LDAP;
use Try::Tiny    ();
use FindBin      ();
use YAML::Tiny   ();
use Data::Dumper ();

my %opt = (
    port   => 6570,
    config => 'config.yaml',
);
Getopt::Long::GetOptions(
    \%opt,
    'port=i',
    'config=s',
    'debug',
    'help',
) || Pod::Usage::pod2usage(1);

Pod::Usage::pod2usage(0) if ( $opt{help} );

if ( $opt{debug} ) {
    print "[info] setting ldap debug\n";
    $ENV{LDAP_DEBUG} = 1;
}

my $config = Try::Tiny::try {
    my $yaml = YAML::Tiny->read("$FindBin::RealBin/" . $opt{config});
    return $yaml->[0];
}
Try::Tiny::catch {
    print "[error] $_";
    exit 1;
};

if ( $opt{debug} ) {
    print "[debug] config:\n" . Data::Dumper::Dumper($config);
}

print "[info] spawning test LDAP server on port " . $opt{port} . "\n";
my $server = Net::LDAP::Server::Test->new( $opt{port}, auto_schema => 1 );

my $client = Net::LDAP->new( 'localhost:' . $opt{port} );
my $ret    = $client->bind();
if ( $ret->code ) {
    die "[error] ldap client: " . $ret->error . "\n";
}

foreach my $user ( keys %{ $config->{users} } ) {
    my %entry = ();
    $entry{objectClass} = $config->{userobjectclass};

    foreach my $key ( keys %{ $config->{users}{$user} } ) {
        $entry{$key} = $config->{users}{$user}{$key};
    }

    my $user_dn = 'uid=' . $config->{users}{$user}{uid} . ',ou=' . $config->{userou} . ',' . $config->{basedn};
    my $ret     = $client->add( $user_dn, attr => [%entry] );
    if ( $ret->code ) {
        die "[error] ldap client: " . $ret->error . "\n";
    }
}

foreach my $group ( keys %{ $config->{groups} } ) {
    my $group_dn = 'cn=' . $config->{groups}{$group}{cn} . ',ou=' . $config->{groupou} . ',' . $config->{basedn};

    my $member_dn = [];
    foreach my $user ( @{ $config->{groups}{$group}{members} } ) {
        my $user_dn = 'uid=' . $config->{users}{$user}{uid} . ',ou=' . $config->{userou} . ',' . $config->{basedn};
        push @{$member_dn}, $user_dn;
    }

    my $ret = $client->add(
        $group_dn,
        attr => [
            cn                         => $config->{groups}{$group}{cn},
            $config->{groupmemberattr} => $member_dn,
            objectClass                => $config->{userobjectclass},
        ],
    );
    if ( $ret->code ) {
        die "[error] ldap client: " . $ret->error . "\n";
    }
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
    }
}

__END__

=pod

=head1 NAME

ldap-test-server.pl - runs a local test LDAP server

=head1 DESCRIPTION

C<ldap-test-server.pl> is a perl script to run a local test LDAP server for development purposes.

LDAP users and groups are defined and added on spinup.  LDAP data does not persist shutdown.

=head1 SYNOPSIS

 ldap-test-server.pl [--port <port number>] [--config <file>] [--debug]
                     [--help]

=head1 OPTIONS

=over

=item --port <port number>

port to bind the LDAP server to; defaults to 6570

=item --config <file>

config file to load; defaults to C<config.yaml>

=item --debug

enable debug output from C<Net::LDAP::Server::Test>

=item --help

print this dialogue

=back

=head1 CONFIGURATION

Users and groups can be configured using the C<config.yaml> file in the project directory.  An example config, C<config.yaml.example>, is provided.

The following base keys are required and used to build other variables on spinup.

=over

=item * basedn

=item * userou

=item * userobjectclass

=item * groupou

=item * groupobjectclass

=item * groupmemberattr

=back

Users are not required to be configured, but if added, each users entry is required to follow the following format; a users key (in the example case C<one> and C<two>), with attribute keys to be added for the user.  The C<uid> key is required, the rest may be any attributes you want to include.

 users:
   one:
     uid: one
     mail: one@example.com
     cn: User One
     userPassword: password
   two:
     uid: two
     mail: two@example.com
     cn: User Two
     userPassword: password

Groups are not required to be configured, but if present, require the following format; a groups key (in the example case C<one>), with C<cn> attributes key.

 groups:
   one:
     cn: Group One
     members:
       - one
       - two

Groups are not required to contain members.  To add members to a group, they must be within the C<members> key, and must match a users key from the users section of the config (in the example case C<one> and C<two>).

=head1 DEPENDENCIES

=over

=item L<strict>

=item L<warnings>

=item L<Getopt::Long>

=item L<Pod::Usage>

=item L<Net::LDAP::Server::Test>

=item L<Net::LDAP>

=item L<Try::Tiny>

=item L<FindBin>

=item L<YAML::Tiny>

=item L<Data::Dumper>

=back

=cut
