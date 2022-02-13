# NAME

ldap-test-server.pl - runs a local test LDAP server

# DESCRIPTION

`ldap-test-server.pl` is a perl script to run a local test LDAP server for development purposes.

LDAP users and groups are defined and added on spinup.  LDAP data does not persist shutdown.

# SYNOPSIS

    ldap-test-server.pl [--port <port number>] [--debug]
                        [--help]

# OPTIONS

- --port

    port to bind the LDAP server to; defaults to 6570

- --debug

    enable debug output from `Net::LDAP::Server::Test`

- --help

    print this dialogue

# DEPENDENCIES

- [Getopt::Long](https://metacpan.org/pod/Getopt%3A%3ALong)
- [Pod::Usage](https://metacpan.org/pod/Pod%3A%3AUsage)
- [Net::LDAP::Server::Test](https://metacpan.org/pod/Net%3A%3ALDAP%3A%3AServer%3A%3ATest)
- [Net::LDAP](https://metacpan.org/pod/Net%3A%3ALDAP)
