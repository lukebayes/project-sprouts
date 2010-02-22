
# Ensure this FILE NAME is the name you want for your library
# This is the primary criteria by which your library will be
# found by users of rubygems and sprouts
name = File.basename(__FILE__).split('.').shift

gem_wrap name do |t|
  t.version       = '0.1.15'
  t.summary       = "AlivePDF is a client side AS3 PDF generation library for Adobe Flash, Flex and AIR."
  t.author        = "Thibault Imbert"
  t.homepage      = "http://alivepdf.bytearray.org/"
  t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget
  platform: universal
  url: http://alivepdf.googlecode.com/files/AlivePDF%200.1.5%20RC.zip
  archive_path: AlivePDF 0.1.5 RC/Sources/bin/AlivePDF.swc
EOF
end
