
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  # version is a dot-delimited, 3 digit version string
  t.version       = '1.3.0'
  # Short summary of your library or project
  t.summary       = "As3 Crypto is a cryptography library written in Actionscript 3 that provides several common algorithms."
  # Your name
  t.author        = 'Metal Hurlant'
  # Your email or - better yet - the address of your project email list
  t.email         = 'projectsprouts@googlegroups.com'
  # The homepage of your library
  t.homepage      = 'http://crypto.hurlant.com/'
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget 
  platform: universal
  url: http://crypto.hurlant.com/demo/srcview/Crypto.zip
  archive_path: ''
EOF
end

# Leave this line alone, we auto-add this gem
# to the global package task
task :package => name
