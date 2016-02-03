# == Class: ghost::setup
#
# This class includes nodejs if not already defined, and creates the
# ghost user and group. It is not meant to be used directly, but
# included from the base Ghost class.
#
# === Copyright
#
# Copyright 2014 Andrew Schwartzmeyer

class ghost::setup {

  if $::ghost::include_nodejs {
    include '::nodejs'
  }

  if $::ghost::manage_group {
    group { $ghost::group:
      ensure => present,
    }
  }

  if $::ghost::manage_user {
    user { $ghost::user:
      ensure     => present,
      gid        => $ghost::group,
      home       => $ghost::home,
      managehome => true,
      require    => Group[$ghost::group],
    }
  }
}
