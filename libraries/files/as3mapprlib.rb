
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  t.version       = '0.85.1'
  t.summary       = "Mappr is a service and application that combines images from Flickr with geolocational information. The Mappr ActionScript 3.0 API gives you access to Mappr's geo-tagged image data."
  t.homepage      = 'http://code.google.com/p/as3mapprlib/'
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget 
  platform: universal
  url: http://as3mapprlib.googlecode.com/files/mappr-.85.zip
  archive_path: mappr/bin/mappr.swc
EOF
end
