
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  t.version       = '1.26.63'
  t.summary       = "Tweener (caurina.transitions.Tweener) is a Class used to create tweenings and other transitions via ActionScript code for projects built on the Flash platform."
  t.author        = 'zisforzeh'
  t.homepage      = 'http://code.google.com/p/tweener/'
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget 
  platform: universal
  url: http://tweener.googlecode.com/files/tweener_1_26_62_as3.zip
  archive_path: ''
EOF
end
