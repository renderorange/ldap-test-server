# NAME

ldap-test-server.pl - runs a local test LDAP server

# DESCRIPTION

`ldap-test-server.pl` is a perl script to run a local test LDAP server for development purposes.

LDAP users and groups are defined and added on spinup.  LDAP data does not persist shutdown.

# SYNOPSIS

    ldap-test-server.pl [--port <port number>] [--config <file>] [--debug]
                        [--help]

# OPTIONS

- --port <port number>

    port to bind the LDAP server to; defaults to 6570

- --config <file>

    config file to load; defaults to `config.yaml`

- --debug

    enable debug output from `Net::LDAP::Server::Test`

- --help

    print this dialogue

# CONFIGURATION

Users and groups can be configured by yaml file in the project directory.  An example config, `config.yaml.example`, is provided.

To get started, rename `config.yaml.example` to `config.yaml`.  Alternately named config files may be used and loaded with the `--config` option.

The following base keys are required and used to build other variables on spinup.

- basedn
- userou
- userobjectclass
- groupou
- groupobjectclass
- groupmemberattr

Users are not required to be configured, but if added, each users entry is required to follow the following format; a users key (in the example case `one` and `two`), with attribute keys to be added for the user.  The `uid` key is required, the rest may be any attributes you want to include.

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

Groups are not required to be configured, but if present, require the following format; a groups key (in the example case `one`), with `cn` attributes key.

    groups:
      one:
        cn: Group One
        members:
          - one
          - two

Groups are not required to contain members.  To add members to a group, they must be within the `members` key, and must match a users key from the users section of the config (in the example case `one` and `two`).

# EXAMPLES

- Run with default port and default config file name

        perl ldap-test-server.pl

- Run with alternate port and alternate config file name

        perl ldap-test-server.pl --port 6571 --config complex.yaml

- Run with additional debug output enabled

        perl ldap-test-server.pl --debug

# DEPENDENCIES

- [strict](https://metacpan.org/pod/strict)
- [warnings](https://metacpan.org/pod/warnings)
- [Getopt::Long](https://metacpan.org/pod/Getopt::Long)
- [Pod::Usage](https://metacpan.org/pod/Pod::Usage)
- [Net::LDAP::Server::Test](https://metacpan.org/pod/Net::LDAP::Server::Test)
- [Net::LDAP](https://metacpan.org/pod/Net::LDAP)
- [Try::Tiny](https://metacpan.org/pod/Try::Tiny)
- [FindBin](https://metacpan.org/pod/FindBin)
- [YAML::Tiny](https://metacpan.org/pod/YAML::Tiny)
- [Data::Dumper](https://metacpan.org/pod/Data::Dumper)
