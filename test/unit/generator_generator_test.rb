require File.join(File.dirname(__FILE__), "test_helper")

require 'generators/generator/generator_generator'

class GeneratorGeneratorTest < Test::Unit::TestCase
  include SproutTestCase

  context "A new generator generator" do

    setup do
      @temp             = File.join(fixtures, 'generators', 'tmp')
      FileUtils.mkdir_p @temp
      @generator        = Sprout::GeneratorGenerator.new
      @generator.path   = @temp
      @generator.logger = StringIO.new
    end

    teardown do
      remove_file @temp
    end

    should "generate a new generator" do
      @generator.input = 'fwee'
      @generator.execute

      lib_dir = File.join(@temp, 'lib')
      assert_directory lib_dir
      
      generators_dir = File.join(lib_dir, 'generators')
      assert_directory generators_dir
      
      generator_file = File.join(generators_dir, 'fwee_generator.rb')
      assert_file generator_file
      
      templates_dir = File.join(generators_dir, 'templates')
      assert_directory templates_dir
      
      template_file = File.join(templates_dir, 'fwee.as')
      assert_file template_file
      
      bin_dir = File.join(@temp, 'bin')
      assert_directory bin_dir
      
      executable_file = File.join(bin_dir, 'fwee')
      assert_file executable_file
    end

  end
end

