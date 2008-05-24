require File.dirname(__FILE__) + '/test_helper'

class MTASCTest <  Test::Unit::TestCase
  include SproutTestCase
  
  def setup
    @start = Dir.pwd
    
    @fixture = File.join(fixtures, 'mtasc')

    @skin_dir = File.expand_path(File.join(fixtures, 'swfmill', 'skin'))
    @skin_swf = 'bin/SomeProjectSkin.swf'
    @skin_xml = 'bin/SomeProjectSkinInput.xml'
    @input = 'src/SomeProject.as'
    @test_input = 'test/SomeProjectRunner.as'
    @output = 'bin/SomeProject.swf'
    
    Dir.chdir(@fixture)
  end
  
  def teardown
    super
    remove_file(@output)
    remove_file('lib/asunit25')
    remove_file(@skin_swf)
    remove_file(@skin_xml)
    Dir.chdir(@start)
  end

  def test_compilation
    mtasc @output do |t|
      t.main = true
      t.header = '800:600:24'
      t.input = @input
    end

    run_task @output
    assert_file(@output)
  end
  
  def test_compilation_with_library
    library :asunit25
    
    mtasc @output => [:asunit25] do |t|
      t.main = true
      t.header = '800:600:24'
      t.input = @test_input
      t.class_path << 'test'
    end
    
    run_task @output
    assert_file(@output)
  end

  def test_compilation_with_swf
    swfmill @skin_swf do |t|
      t.input = @skin_dir
    end
    
    # By setting the @skin_swf as prerequisite,
    # the MTASC will set that output to it's
    # -swf parameter
    mtasc @output => [@skin_swf] do |t|
      t.main = true
      t.input = @input
    end
    
    run_task @output
    assert_file @skin_swf
    assert_file @output
    assert(File.size(@output) > 10000, "Generated swf should have an image embeded, and be greater than 10k")
  end
  
  def test_linux_std_class_path
    mtasc @output do |t|
      t.main = true
      t.include_std = true
      t.header = '800:600:24'
      t.input = @input
    end

# Had to comment this because it only runs on linux!    
#    t = Rake::Task[@output]
#    assert(t.to_shell.index('/std'), "MTASCTask should add std lib to class_path for Linux Users")
  end
end
