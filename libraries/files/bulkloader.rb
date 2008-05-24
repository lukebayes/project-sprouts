name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  t.version       = '0.175.1'
  t.summary       = "A library for managing multiple loadings with Actionscript 3 (AS3)."
  t.author        = 'Arthur Debert'
  t.email         = 'arthur@stimuli.com'
  t.homepage      = 'http://code.google.com/p/bulk-loader/'
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget
  platform: universal
  url: http://bulk-loader.googlecode.com/files/bulkloader_rev175.zip
  archive_path: bulkloader_rev175/src
EOF
end

task :package => name
