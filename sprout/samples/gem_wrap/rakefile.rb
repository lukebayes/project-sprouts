require 'sprout'

desc "Wrap the asunit3 library in a rubygem"
gem_wrap :asunit3 do |t|
  t.version       = '3.2.0'
  t.summary       = "AsUnit3 is an ActionScript unit test framework for AIR, Flex 2/3 and ActionScript 3 projects"
  t.author        = "Luke Bayes and Ali Mills"
  t.email         = "projectsprouts@googlegroups.com"
  t.homepage      = "http://www.asunit.org"
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget 
  platform: universal
  url: http://projectsprouts.googlecode.com/files/asunit3-1.1.zip
  source_path: ''
EOF
end

