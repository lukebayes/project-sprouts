
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  t.version       = '2.2.2'
  t.summary       = "The Cairngorm Microarchitecture is a lightweight yet prescriptive framework for rich Internet application (RIA) development."
  t.author        = 'Adobe, Inc.'
  t.homepage      = 'http://labs.adobe.com/wiki/index.php/Cairngorm'
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget 
  platform: universal
  url: http://weblogs.macromedia.com/amcleod/archives/downloads/Cairngorm2_2_1-src.zip
  archive_path: Cairngorm
EOF
end
