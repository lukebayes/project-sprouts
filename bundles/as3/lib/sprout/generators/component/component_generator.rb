
class ComponentGenerator < Sprout::Generator::NamedBase  # :nodoc:

  def manifest
    record do |m|
      if(!user_requested_test)
        m.directory full_class_dir
        m.template 'Component.mxml', full_class_path.gsub(/.as$/, '.mxml')
      end
 
      m.directory full_test_dir
      m.template 'VisualTestCase.as', full_test_case_path
      
      m.template 'TestSuite.as', File.join(test_dir, 'AllTests.as'), :collision => :force
    end
  end
    
end
