require File.join(File.dirname(__FILE__), "test_helper")

require 'sprout/generators/ruby/ruby_generator'

class RubyGeneratorTest < Test::Unit::TestCase
  include SproutTestCase

  context "A generated ruby application" do

    setup do
      @temp = File.join(fixtures, 'generators', 'ruby')
      FileUtils.mkdir_p @temp
      @generator = Sprout::RubyGenerator.new
      @generator.path = @temp
      @generator.logger = StringIO.new
    end

    teardown do
      #remove_file @temp
    end

    should "generate a new ruby application" do
      @generator.input = 'SomeProject'
      @generator.version = '4.2.pre'
      @generator.lib = 'libs'
      @generator.execute

      project_dir = File.join @temp, 'some_project'
      assert_file project_dir

      gem_file = File.join project_dir, 'Gemfile'
      assert_file gem_file

      lib_dir = File.join project_dir, 'libs'
      assert_file lib_dir

      module_file = File.join lib_dir, 'some_project.rb'
      assert_file module_file do |content|
        assert_matches /VERSION/, content
        assert_matches /4.2.pre/, content
      end

      classes_dir = File.join lib_dir, 'some_project'
      assert_file classes_dir

      main_file = File.join classes_dir, 'base.rb'
      assert_file main_file

      test_dir = File.join project_dir, 'test'
      assert_file test_dir

      unit_dir = File.join test_dir, 'unit'
      assert_file unit_dir

      fixtures_dir = File.join test_dir, 'fixtures'
      assert_file fixtures_dir

      bin_dir = File.join project_dir, 'bin'
      assert_file bin_dir

      exe_file = File.join bin_dir, 'some-project'
      assert_file exe_file do |content|
        assert_matches /some_project/, content
        assert_matches /SomeProject::Base.new/, content
      end

    end
  end
end

