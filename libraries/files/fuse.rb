
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  t.version       = '2.1.4'
  t.summary       = "Fuse Animation Package"
  t.author        = 'Moses Gunesch (FuseKit)'
  t.homepage      = 'http://www.mosessupposes.com/Fuse/'
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget 
  platform: universal
  url: http://www.mosessupposes.com/Fuse/fuse2.1.4.zip
  archive_path: 'fuse2.1.4'
EOF
end
