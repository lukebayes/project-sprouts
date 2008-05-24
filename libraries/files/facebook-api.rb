
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  t.version       = '0.7.1'
  t.summary       = "The Facebook Actionscript API provides an interface between the Facebook REST based API and Flash/Flex based applications."
  t.author        = 'jcrist.pbking, fabianhore'
  t.homepage      = 'http://code.google.com/p/facebook-actionscript-api/'
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget 
  platform: universal
  url: http://facebook-actionscript-api.googlecode.com/files/facebook_as3_api_swc_v0.7.zip
  swc_path: facebook_as3_api_swc_v0.7/facebook_as3_api.swc
EOF
end
