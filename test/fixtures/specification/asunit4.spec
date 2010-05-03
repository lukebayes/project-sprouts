
Sprout::Specification.new do |s|
  s.name        = "asunit4"
  s.version     = "4.2.pre"
  s.authors     = ["Luke Bayes", "Ali Mills", "Robert Penner"]
  s.email       = "asunit-users@lists.sourceforge.net"
  s.homepage    = "http://asunit.org"
  s.summary     = "The fastest and most flexible ActionScript unit test framework"
  s.description = <<EOS
 AsUnit is the only ActionScript unit test framework that
 supports every development and runtime environment that is currently available. 
 This includes Flex 2, 3, 4, AIR 1 and 2, Flash Lite, and of course the 
 Flash Authoring tool.
EOS

  s.add_file_target do |t|
    t.add_library :src, ['src', 'lib/as3reflection']
    t.add_library :swc, 'ext/AsUnit-4.1.pre.swc'
  end

end

