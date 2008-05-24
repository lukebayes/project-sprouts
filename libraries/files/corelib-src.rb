
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  t.version       = '0.9.7'
  t.summary       = "The corelib project is an ActionScript 3 Library that contains a number of classes and utilities for working with ActionScript 3. These include classes for MD5 and SHA 1 hashing, Image encoders, and JSON serialization as well as general String, Number and Date APIs."
  t.author        = "Core Library Group"
  t.email         = "as3corelib@googlegroups.com"
  t.homepage      = "http://as3corelib.googlecode.com"
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget 
  platform: universal
  url: http://as3corelib.googlecode.com/files/corelib-.90.zip
  archive_path: corelib/src
EOF
end
