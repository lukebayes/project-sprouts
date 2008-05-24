
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  # version is a dot-delimited, 3 digit version string
  t.version       = '0.0.0'
  # Short summary of your library or project
  t.summary       = ""
  # Your name
  t.author        = ''
  # Your email or - better yet - the address of your project email list
  t.email         = 'projectsprouts@googlegroups.com'
  # The homepage of your library
  t.homepage      = ''
  # Any gem dependencies that your library requires
  # (Go easy here, 99 out of 100 libraries should not
  # need this)
  # t.add_dependency('name', 'version')
  # This is the most important bit!
  # * url is the full url to a zip archive of your library
  # It must be hosted somewhere publicly available like
  # rubyforge, sourceforge, osflash, etc.
  # * archive_path is the relative path to either the source
  # root or swc file within your zip archive.
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget 
  platform: universal
  url: 
  archive_path: 
EOF
end

# Leave this line alone, we auto-add this gem
# to the global package task
task :package => name
