
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  t.version       = '3.2.6'
  t.summary       = "AsUnit3 is an ActionScript unit test framework for AIR, Flex 2/3 and ActionScript 3 projects"
  t.author        = "Luke Bayes and Ali Mills"
  t.email         = "projectsprouts@googlegroups.com"
  t.homepage      = "http://www.asunit.org"
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget 
  platform: universal
  url: http://projectsprouts.googlecode.com/files/asunit3-1.6.zip
  md5: 7f7181c7e34087ec6d5aef806867eec5
  archive_path: ''
EOF
end
