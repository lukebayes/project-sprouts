
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  t.version       = '1.0.1'
  t.summary       = "SWX is the native data format for the Flash Platform."
  t.author        = 'Aral Balkan'
  t.email         = 'http://osflash.org/mailman/listinfo/swx_osflash.org'
  t.homepage      = 'http://swxformat.org'
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget 
  platform: universal
  url: http://swxformat.org/downloads/swx_aslib_1.0.zip
  archive_path: swx_aslib_1.0
EOF
end
