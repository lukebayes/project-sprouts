
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  t.version       = '1.0.0'
  t.summary       = "FZlib is a port of Zlib 1.1.3 in ActionScript."
  t.author        = "Marco Fucci"
  t.email         = "fzlib@wizhelp.com"
  t.homepage      = "http://www.wizhelp.com/fzlib/"
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget
  platform: universal
  url: http://www.wizhelp.com/fzlib/files/FZlib-1.0.0.zip
  archive_path: FZlib/bin/FZlib.swc
EOF
end
