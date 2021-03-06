require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::homebrewdir}/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include nginx

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # node versions
  nodejs::version { 'v0.6': }
  nodejs::version { 'v0.8': }
  nodejs::version { 'v0.10': }
  nodejs::version { 'v0.12.0': }

  # default ruby versions
  ruby::version { '1.9.3': }
  ruby::version { '2.0.0': }
  ruby::version { '2.1.0': }
  ruby::version { '2.1.1': }
  ruby::version { '2.1.2': }

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }

  # customisations by gravityrail
  include brewcask
  include heroku

  # browsers
  package { 'firefox': provider => 'brewcask' }
  package { 'google-chrome': provider => 'brewcask' }

  # office
  package { 'libreoffice': provider => 'brewcask' }

  # networking
  package { 'viscosity': provider => 'brewcask' }

  # utilities
  package { 'sizeup': provider => 'brewcask' }
  package { 'flux': provider => 'brewcask' }
  package { 'airfoil': provider => 'brewcask' } 

  # entertainment
  package { 'utorrent': provider => 'brewcask' }
  package { 'vlc': provider => 'brewcask' }
  package { 'chromecast': provider => 'brewcask' }

  # work
  package { 'tower': provider => 'brewcask' }    # git client
  package { 'versions': provider => 'brewcask' } # subversion client
  package { 'sublime-text': provider => 'brewcask' }
  package { 'slack': provider => 'brewcask' }
  package { 'skype': provider => 'brewcask' }
  package { 'screenhero': provider => 'brewcask' }
  package { 'colloquy': provider => 'brewcask' }
  package { 'balsamiq-mockups': provider => 'brewcask' }

  # files (I have a Synology box at home)
  package { 'synologyeiauthenticator': provider => 'brewcask' }
  package { 'synology-photo-station-uploader': provider => 'brewcask' }
  # TODO: sudo
  # package { 'synology-cloud-station': provider => 'brewcask' }
  package { 'synology-assistant': provider => 'brewcask' }
  package { 'transmit': provider => 'brewcask' }

  # creative (I have a Bamboo graphics tablet)
  # TODO: sudo
  # package { 'wacom-bamboo-tablet': provider => 'brewcask' }
  
  # games
  package { 'scummvm': provider => 'brewcask' } # TODO: download games

  # services
  package { 'mysql': provider => 'homebrew' } 
  package { 'postgresql': provider => 'homebrew' } 
  # TODO: sudo
  # package { 'virtualbox': provider => 'brewcask' } 
  package { 'docker': provider => 'homebrew' } 

  # wordpress
  package { 'php56': provider => 'homebrew' }
  package { 'wp-cli': provider => 'homebrew' }
}
