# == Class: ghost::blog
#
# This class sets up a Ghost blog instance. The user and group must
# exist (can be created with the base class), and nodejs and npm must
# be installed.
#
# It will install the latest version of Ghost. Subsequent updates can
# be forced by deleting the archive.
#
# It can also daemonize the Ghost blog instance using supervisor.
#
# === Copyright
#
# Copyright 2014 Andrew Schwartzmeyer
#
# === TODO
#
# - add database setup to template
# - support other operating systems

define ghost::blog(
  $blog           = $title,                 # Name of blog
  $user           = 'ghost',                # Ghost instance should run as its own user
  $group          = 'ghost',                # Group the ghost instance should run as
  $home           = "/home/ghost/${title}", # Root of Ghost instance
  $manage_home    = false,
  $version        = '0.7.6',                # Version to install via npm
  $package_name   = 'ghost',                # Name of the package to install via npm
  $ensure_service = 'running',              # Ensure the service is running or stopped
  $manage_service = true,                   # Whether or not to manage the service
  $stdout_logfile = "/var/log/ghost_${title}.log",
  $stderr_logfile = "/var/log/ghost_${title}_err.log",

  # Parameters below affect Ghost's config through the template
  $manage_config  = true, # Manage Ghost's config.js

  # For a working blog, these must be specified and different per instance
  $url            = 'https://localhost', # Required URL of blog
  $host           = '127.0.0.1',                 # Host to listen on if not using socket
  $port           = '2368',                      # Port of host to listen on

  # Mail settings (see http://docs.ghost.org/mail/)
  $transport      = '', # Mail transport
  $fromaddress    = '', # Mail from address
  $mail_options   = {}, # Hash for mail options
) {
  # These packages needed to be present in the original module that installs
  # ghost by downloading and extracting a zip file. Now ghost is installed via
  # npm.
  #ensure_packages(['unzip', 'curl'])

  validate_string($blog)
  validate_string($user)
  validate_string($group)
  validate_string($url)
  validate_string($version)
  validate_string($host)
  validate_string($transport)
  validate_string($fromaddress)

  validate_absolute_path($home)
  validate_absolute_path($stdout_logfile)
  validate_absolute_path($stderr_logfile)

  validate_bool($manage_service)
  validate_bool($manage_config)

  validate_re($port, '\d+')
  validate_hash($mail_options)

  if $manage_service {
    validate_re($ensure_service, '(running|present|stopped|absent)')
  }

  package { $package_name:
    provider => 'npm',
    ensure   => $version,
  }

  if $manage_home {
    file { $home:
      ensure => 'directory',
      owner  => $user,
      group  => $group,
    }
  }

  if $manage_config {
    file { "${home}/config.js":
      content => template('ghost/config.js.erb'),
      owner   => $user,
      group   => $group,
    }
  }

  if $manage_service {
    service { "ghost-blog-${blog}":
      ensure => $ensure_service,
    }

    if $manage_config {
      File["${home}/config.js"] ~> Service["ghost-blog-${blog}"]
    }
  }
}
