
class FlexUnit
  include Sprout::Library

  file_target :universal do |t|
    t.url = "http://digitalprimate.com/flexunit.zip"
    t.md5 = "abcd"
    t.archive_type = :zip

    t.add_library :swc, "primates/bin/FlexUnit.swc"
    t.add_library :src, "primates/dist" 
  end

end

#FlexUnit.resolve(:src, "lib")

