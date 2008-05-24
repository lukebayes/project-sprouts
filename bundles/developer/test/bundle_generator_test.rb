require File.dirname(__FILE__) + '/test_helper'

class BundleGeneratorTest < Test::Unit::TestCase
  include GeneratorTestHelper
  
  def setup
    super
    @start = Dir.pwd
    @name = 'Haxe'
    @name_lower
    @fixture = File.expand_path(File.join(fixtures, 'bundle'))
    Sprout::Sprout.project_name = @name
    Sprout::Sprout.project_path = @fixture
    Dir.chdir(@fixture)

    remove_file(@name_lower)
  end
  
  def teardown
    remove_file(@name)
    Dir.chdir(@start)
  end
  
  # Bundles are created like:
  # sprout -n developer -g bundle --generators 'project class test suite' Haxe
  def test_generate_bundle
#    params = ['', @name]
#    run_generator('developer', 'tool', params, @local_generators)
  end
  
  
end
