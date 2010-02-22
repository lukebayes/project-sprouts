
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
    t.version       = '0.8.9'
    t.summary       = 'A library to include the mate framework into your projects'
    t.author        = 'http://mate.asfusion.com/'
    t.email         = 'projectsprouts@googlegroups.com'
    t.homepage      = 'http://mate.asfusion.com/'
    t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget
  platform: universal
  url: http://mate-framework.googlecode.com/files/Mate_08_9.swc
  archive_type: 'swc'  
  archive_path: 'Mate_08_9.swc'  
EOF
end

task :package => name