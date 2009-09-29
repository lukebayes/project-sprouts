
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  t.version       = '1.0.1'
  t.summary       = "XPath4AS2 is an implementation of XPath for ActionScript"
  t.author        = "Neeld Tanksley"
  t.email         = "projectsprouts@googlegroups.com"
  t.homepage      = "http://xfactorstudio.com"
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget 
  platform: universal
  filename: asunit3.zip
  library_path: asunit3
  archive_type: zip
  url: http://stoletheshow.com/fileadmin/xpath4as2-strict-translate.zip
  archive_path: 'xpath4as2-strict-translate'
EOF
end
