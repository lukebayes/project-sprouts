
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  # version is a dot-delimited, 3 digit version string
  t.version       = '1.2.1'
  # Short summary of your library or project
  t.summary       = "Degrafa is a declarative graphics framework for Flex."
  # Your name
  t.author        = 'Ben Stucki'
  # Your email or - better yet - the address of your project email list
  t.email         = 'projectsprouts@googlegroups.com'
  # The homepage of your library
  t.homepage      = 'http://code.google.com/p/degrafa/'
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget 
  platform: universal
  url: http://degrafa.googlecode.com/files/Degrafa-.1.2.zip
  archive_path: Degrafa.swc
EOF
end

# Leave this line alone, we auto-add this gem
# to the global package task
task :package => name
