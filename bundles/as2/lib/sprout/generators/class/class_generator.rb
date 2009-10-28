
# Generate a new ActionScript 3.0 class,
# test case and test suite.
#
# This generator can be executed as follows:
# 
#   sprout -n as3 SomeProject
#   cd SomeProject
#   script/generator class utils.MathUtil
#
# Be sure to check out NamedBase to learn more about what kinds of class names
# can be accepted.
#
# If the class name passed into this generator ends with 'Test', only a test case
# and test suite will be generated.
#
class ClassGenerator < Sprout::Generator::NamedBase  # :nodoc:

  def manifest
    record do |m|
#      m.class_collisions class_dir, "#{class_name}Controller", "#{class_name}ControllerTest", "#{class_name}Helper"

      if(!user_requested_test)
        m.directory full_class_dir
        m.template 'Class.as', full_class_path
      end
 
      m.directory full_test_dir
      m.template 'TestCase.as', full_test_case_path
      
      m.template 'TestSuite.as', File.join(test_dir, 'AllTests.as'), :collision => :force
    end
  end
    
end
