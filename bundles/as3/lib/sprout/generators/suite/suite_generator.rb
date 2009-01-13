
# Generate a new ActionScript 3.0 test suite
# This generator can be executed as follows:
# 
#   sprout -n as3 SomeProject
#   cd SomeProject
#   script/generator suite
#
class SuiteGenerator < Sprout::Generator::NamedBase # :nodoc:

  def manifest
    record do |m|
      m.template 'TestSuite.as', File.join(test_dir, 'AllTests.as'), :collision => :force
    end
  end
  
end
