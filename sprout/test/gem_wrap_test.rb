require File.dirname(__FILE__) + '/test_helper'

class GemWrapTest <  Test::Unit::TestCase
  include SproutTestCase
  
  def setup
    remove_file(File.join(fixtures, 'gem_wrap', 'pkg'))
    fixture = File.join(fixtures, 'gem_wrap')
    @start = Dir.pwd
    Dir.chdir(fixture)

    @gem = File.join('pkg', 'sprout-asunit3-library-3.2.0.gem')
    @template_extension = 'template'
    @gem_template = File.join('pkg', 'sprout-mxml-template-0.1.0.gem')
  end

  def teardown
    super
    Dir.chdir(@start)
   remove_file(File.join(fixtures, 'gem_wrap', 'pkg'))
  end
  
  def test_wrap_library
    gem_wrap :asunit3 do |t|
      t.version       = '3.2.0'
      t.summary       = "AsUnit3 is and ActionScript unit test framework for AIR, Flex 2/3 and ActionScript 3 projects"
      t.author        = "Luke Bayes and Ali Mills"
      t.email         = "projectsprouts@googlegroups.com"
      t.homepage      = "http://www.asunit.org"
      t.sprout_spec   =<<EOF
- !ruby/object:Sprout::RemoteFileTarget 
  platform: universal
  url: http://projectsprouts.googlecode.com/files/asunit3-1.1.zip
  source_path: ''
EOF
    end
    
    # puts "GemWrapTest.test_wrap_library emitting output"
    # run_task :asunit3
    # assert_file(@gem)
  end

end
