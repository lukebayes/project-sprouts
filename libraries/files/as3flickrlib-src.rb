
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  t.version       = '0.87.2'
  t.summary       = 'ActionScript 3.0 API for Flickr'
  t.author        = 'Charles Bihis, Mike Potter, Darron Schall and Mike Chambers'
  t.homepage      = 'http://actionscript3libraries.riaforge.org/'
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget 
  platform: universal
  url: http://as3flickrlib.googlecode.com/files/flickr-.87.zip
  archive_path: flickr-.87/src
EOF
end
