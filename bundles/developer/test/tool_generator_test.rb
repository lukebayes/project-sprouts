require File.dirname(__FILE__) + '/test_helper'

class ToolGeneratorTest < Test::Unit::TestCase
  include GeneratorTestHelper
  
  def setup
    super
    @start = Dir.pwd
    @tool_name = 'Flex3SDK'
    @fixture = File.expand_path(File.join(fixtures, 'tool'))
    Sprout::Sprout.project_name = @tool_name
    Sprout::Sprout.project_path = @fixture
    Dir.chdir(@fixture)

#    remove_file(@tool_name)
  end
  
  def teardown
    remove_file(@tool_name)
    Dir.chdir(@start)
  end
  
  def ensure_binary(tool, name)
    binary_file = File.join(@fixture, tool, 'bin', name)
    assert_file(binary_file)
    content = File.open(binary_file, 'r').read
    expected = "exe = Sprout::Sprout.get_executable('sprout-#{tool}-tool', 'bin/#{name}'"
    assert(content.index(expected), "#{tool} created a binary for #{File.basename(binary_file)}")
  end
  
  def test_generate_tool
    spec_path = File.join(@fixture, 'flex3sdk.spec')
    params = ['--gem-version', '4.5.6', 
              '--exe', 'bin/mxmlc', 
              '--exe', 'bin/asdoc', 
              '--exe', 'bin/compc', 
              '--sprout-spec', spec_path,
              @tool_name]
    run_generator('developer', 'tool', params, @local_generators)

    # Verify version file created correctly
    version_file = File.join(@fixture, @tool_name.downcase, 'lib', 'sprout', @tool_name, 'version.rb') 
    assert_file version_file
    content = File.open(version_file, 'r').read
    assert(content.index("MAJOR = 4"), "Major revision is not correct")
    assert(content.index("MINOR = 5"), "Minor revision is not correct")
    assert(content.index("TINY  = 6"), "Tiny revision is not correct")

    # Verify each expected binary file
    ensure_binary(@tool_name.downcase, 'mxmlc')
    ensure_binary(@tool_name.downcase, 'asdoc')
    ensure_binary(@tool_name.downcase, 'compc')
    
    # Verify rakefile
    assert_file(File.join(@fixture, @tool_name.downcase, 'rakefile.rb'))
    
    # Verify sprout.spec
    spec_file = File.join(@fixture, @tool_name.downcase, 'sprout.spec')
    assert_file(spec_file)
    content = File.open(spec_file, 'r').read
    assert(content.index('url: http://download.macromedia.com/pub/flex/sdk/flex_sdk_2.zip'), "Spec file was not written properly")
  end
  
  
end
