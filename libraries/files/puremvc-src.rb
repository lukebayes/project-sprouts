
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  t.version       = '2.0.3'
  t.summary       = "PureMVC is a lightweight framework for creating applications in ActionScript 3, based upon the classic Model-View-Controller design meta-pattern."
  t.author        = 'Cliff Hall'
  t.email         = 'cliff@puremvc.org'
  t.homepage      = 'http://www.puremvc.org'
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget 
  platform: universal
  url: http://puremvc.org/pages/downloads/AS3/PureMVC_AS3.zip
  archive_path: PureMVC_AS3_2_0_3/bin/PureMVC_AS3_2_0_3.swc
  url: http://puremvc.org/pages/downloads/PureMVC.zip
  archive_path: PureMVC_AS3_2_0_3/src
EOF
end
