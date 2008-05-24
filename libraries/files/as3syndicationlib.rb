
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  t.version       = '0.85.1'
  t.summary       = "Use the syndication library to parse Atom and all versions of RSS easily. This library hides the differences between the formats so you can parse any type of feed without having to know what kind of feed it is."
  t.homepage      = 'http://code.google.com/p/as3syndicationlib/'
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget 
  platform: universal
  url: http://as3syndicationlib.googlecode.com/files/xmlsyndication-.85.zip
  archive_path: xmlsyndication/bin/xmlsyndication.swc
EOF
end
