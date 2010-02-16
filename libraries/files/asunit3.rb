
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  t.version       = '4.0.14'
  t.summary       = "AsUnit3 is an ActionScript unit test framework for AIR, Flex 2/3 and ActionScript 3 projects"
  t.author        = "Luke Bayes and Ali Mills"
  t.email         = "projectsprouts@googlegroups.com"
  t.homepage      = "http://asunit.org"
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget 
  platform: universal
  filename: asunit3.zip
  library_path: asunit3
  archive_type: zip
  url: http://github.com/lukebayes/asunit/zipball/4.0.3
  md5: 243c963f4d7191081ae200600aa698cb
  archive_path: 'lukebayes-asunit-e2af845/as3/src'
EOF
end
