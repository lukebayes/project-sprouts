
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  t.version       = '1.5.1'
  t.summary       = "Open Source realtime 3D engine for Flash"
  t.author        = "neoriley, C4RL054321, r.hauwert, tim.knip"
  t.homepage      = "http://www.papervision3d.org/"
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget 
  platform: universal
  url: http://papervision3d.googlecode.com/files/Papervision3D_1_5.zip
  archive_path: PV3D_1_5/src
EOF
end
