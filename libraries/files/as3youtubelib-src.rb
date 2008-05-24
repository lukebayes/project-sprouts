
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  t.version       = '0.85.1'
  t.summary       = 'The YouTube API provides an ActionScript 3.0 interface to search videos from YouTube.'
  t.homepage      = 'http://code.google.com/p/as3youtubelib/'
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget 
  platform: universal
  url: http://as3youtubelib.googlecode.com/files/youtube-.85.zip
  archive_path: youtube/src
EOF
end
