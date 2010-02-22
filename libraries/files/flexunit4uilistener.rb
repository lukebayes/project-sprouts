
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  t.version       = '1.0.0'
  t.summary       = 'ActionScript 3.0 / Flex framework for unit testing'
  t.author        = 'Adobe Systems Incorporated'
  t.email         = "projectsprouts@googlegroups.com"
  t.homepage      = 'http://www.flexunit.org/'
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget
  platform: universal
  url: http://flexunit.digitalprimates.net:8080/job/FlexUnit4-Flex3.4/49/artifact/flexunit-4.0.0.zip
  install_path: '../flexunit-uilistener-4.0.0.swc'
  archive_path: flexunit/flexunit-uilistener-4.0.0.swc
EOF
end

task :package => name