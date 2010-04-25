
Sprout::Specification.new do |s|
  s.name        = "flex4sdk"
  s.version     = "4.0.pre"
  s.author      = "Adobe, Inc."
  s.email       = ["projectsprouts@googlegroups.com"]
  s.homepage    = "http://www.adobe.com/products/flex"
  s.summary     = "Adobe Flex 4 SDK including mxmlc, compc, asdoc, adl, adt, optimizer and fdb"
  s.description = "The Flex 4 SDK Rubygem is brought to you by Project Sprouts (http://projectsprouts.org)"

  # TODO: Add license agreement to post_install hook

  s.files       = FileList["flex4sdk/**/*"]

  s.add_remote_file_target do |t|
    t.platform     = :win32
    t.archive_type = :zip
    t.url          = "http://download.macromedia.com/pub/labs/flex/4/flex4sdk_b2_100509.zip"
    t.md5          = "6a0838c5cb33145fe88933778ddb966d"
    t.add_executable :mxmlc,     "bin/mxmlc.exe"
    t.add_executable :adl,       "bin/adl.exe"
    t.add_executable :compc,     "bin/compc.exe"
    t.add_executable :asdoc,     "bin/asdoc.exe"
    t.add_executable :adt,       "bin/adt.exe"
    t.add_executable :fdb,       "bin/fdb.exe"
    t.add_executable :optimizer, "bin/optimizer.exe"
  end

  s.add_remote_file_target do |t|
    t.platform     = :universal
    t.archive_type = :zip
    t.url          = "http://download.macromedia.com/pub/labs/flex/4/flex4sdk_b2_100509.zip"
    t.md5          = "6a0838c5cb33145fe88933778ddb966d"
    t.add_executable :mxmlc,     "bin/mxmlc"
    t.add_executable :adl,       "bin/adl"
    t.add_executable :compc,     "bin/compc"
    t.add_executable :asdoc,     "bin/asdoc"
    t.add_executable :adt,       "bin/adt"
    t.add_executable :fdb,       "bin/fdb"
    t.add_executable :optimizer, "bin/optimizer"
  end
end

