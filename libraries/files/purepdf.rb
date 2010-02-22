
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  t.version       = '0.23.20100210'
  t.summary       = "purepdf is a complete pdf library for actionscript. Package without font support."
  t.author        = "Alessandro Crugnola"
  t.email         = "purepdf-discuss@googlegroups.com"
  t.homepage      = "http://code.google.com/p/purepdf/"
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget
  platform: universal
  url: http://purepdf.googlecode.com/files/purePDF_0.23.20100210.zip
  archive_path: purePDF.swc
EOF
end
