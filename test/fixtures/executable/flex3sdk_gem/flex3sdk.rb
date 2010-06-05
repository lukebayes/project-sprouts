
exe = OpenStruct.new({
                      :name => :mxmlc, 
                      :pkg_name => 'flex3sdk', 
                      :pkg_version => '3.0.0', 
                      :platform => :macosx,
                      :path => File.join(File.dirname(__FILE__), 'mxmlc')
                     })

Sprout::Executable.register exe

