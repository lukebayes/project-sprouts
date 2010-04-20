
class FakeAsUnit
  include Sprout::Library

  add_file_target :universal do |t|
    # First declaration is the default?
    # Or should we prefer one over the other?
    t.add_library :swc, "asunit4.0/bin/AsUnit.swc"
    t.add_library :src, "asunit4.0/dist"
  end

end

#AsUnit.resolve(:swc, "lib")

