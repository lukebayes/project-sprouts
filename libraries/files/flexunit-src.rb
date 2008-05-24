
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  t.version       = '0.85.1'
  t.summary       = 'ActionScript 3.0 framework for unit testing'
  t.author        = "Core Library Group"
  t.homepage      = 'http://code.google.com/p/as3flexunitlib/'
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget 
  platform: universal
  url: http://as3flexunitlib.googlecode.com/files/flexunit-.85.zip
  archive_path: flexunit/src
EOF
end
