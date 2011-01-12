
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  t.version       = '4.0.20'
  t.summary       = "AsUnit4 is an ActionScript unit test framework for AIR, Flex 2/3 and ActionScript 3 projects"
  t.author        = "Luke Bayes and Ali Mills"
  t.email         = "projectsprouts@googlegroups.com"
  t.homepage      = "http://asunit.org"
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget 
  platform: universal
  filename: asunit4.zip
  library_path: asunit4
  archive_type: zip
  url: https://download.github.com/patternpark-asunit-4.0.3-0-ge2af845.zip
  md5: 9fa5c9e95a34319d2c7851c6de489d65
  archive_path: 'patternpark-asunit-e2af845/asunit-4/src'
EOF
end
