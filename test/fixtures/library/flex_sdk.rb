
class FlexSDK
  include Sprout::Tool

  file_target :windows do |t|
    t.url = "http://adobe.com/win/flex3sdk.zip"
    t.md5 = "abcd"

    t.add_executable :mxmlc, "bin/mxmlc.exe"
    t.add_executable :adl, "bin/adl.exe"
    t.add_executable :compc, "bin/compc.exe"
    t.add_executable :asdoc, "bin/asdoc.exe"
    t.add_executable :adt, "bin/adt.exe"
    t.add_executable :fdb, "bin/fdb.exe"
    t.add_executable :optimizer, "bin/optimizer.exe"
  end

  file_target :universal do |t|
    t.url = "http://adobe.com/win/flex3sdk.zip"
    t.md5 = "abcd"

    t.add_executable :mxmlc, "bin/mxmlc"
    t.add_executable :adl, "bin/adl"
    t.add_executable :compc, "bin/compc"
    t.add_executable :asdoc, "bin/asdoc"
    t.add_executable :adt, "bin/adt"
    t.add_executable :fdb, "bin/fdb"
    t.add_executable :optimizer, "bin/optimizer"
  end

end

#path_to_exe = FlexSDK.executable(:mxmlc)

