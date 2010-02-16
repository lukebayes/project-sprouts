
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  t.version       = '3.4.1'
  t.summary       = "Flex Data Visualization Libraries"
  t.author        = "Adobe, Inc."
  t.email         = "projectsprouts@googlegroups.com"
  t.homepage      = "http://blogs.adobe.com/flex/archives/2009/08/status_of_flex_data_visualizat.html"
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget 
  platform: universal
  filename: datavisualization_sdk3.4.zip
  library_path: flexdatavis
  archive_type: zip
  url: http://download.macromedia.com/pub/flex/sdk/datavisualization_sdk3.4.zip
  archive_path: 'libs/datavisualization.swc'
EOF
end
