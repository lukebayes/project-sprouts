require File.dirname(__FILE__) + '/test_helper'

class ZipTest <  Test::Unit::TestCase
  include SproutTestCase
  
  def setup
    fixture = File.join(fixtures, 'gem_wrap')
    @package = File.join(fixture, 'pkg')
#    FileUtils.mkdir_p(pkg)

    @input = File.join(fixture, 'template')
    @output = File.join(fixture, 'pkg', 'template.zip')
    @nil_output = File.join(fixture, 'template.zip')
  end

  def teardown
    super
    remove_file @package
    remove_file @output
    remove_file @nil_output
  end
  
  def test_zip
    zip @output do |t|
      t.input   = @input
    end
    
    run_task @output
    assert_file(@output)
  end

  def test_bad_input
    zip @output do |t|
      t.input   = "foo"
    end

    assert_raise Sprout::ZipError do 
      run_task @output
    end
    
  end

  def test_directory_output
    zip :archive3 do |t|
      t.input   = @input
      t.output  = File.dirname(@output)
    end
    
    run_task :archive3
    assert_file(@output)
  end

end
