##
# This is an example of how I think generators ought to look.
#
# The current interface to Rubigen is unacceptable because
# of it's dependence on duplicate boilerplate, and global 
# state.
#
# should also be a generator helper that allows you 
# to reference an existing directory on disk, and will 
# emit a new generator (gem?) that would recreate those files:
#
#     sprout-generator-importer ~/Projects/SomeProject
#
class AppGenerator
  include Sprout::Generator

  ##
  # The path where classes should usually be created.
  add_param :src, String, { :default => 'src' }

  ##
  # The path where test cases should be created.
  add_param :test, String, { :default => 'test' }

  ##
  # The path where libraries should be added.
  add_param :lib, String, { :default => 'lib' }

  ##
  # The path where binaries should be created.
  add_param :bin, String, { :default => 'bin' }

  ##
  # The path where all assets should be created.
  add_param :assets, String, { :default => 'assets' }

  ##
  # The path where skins should be created.
  add_param :skins, String, { :default => 'skins' }

  ##
  # The path where scripts are created.
  add_param :script, String, { :default => 'script' }

  ##
  # The name of the project that should be created.
  add_param :name, String, { :reader => :get_name }

  ##
  # Prevent the creation of a lib directory.
  add_param :no_lib, Boolean

  ##
  # Prevent the creation of an assets directory.
  add_param :no_assets, Boolean

  def manifest
    directory name do
      file 'rakefile.rb.erb', 'rakefile.rb'
      file 'Gemfile.erb', 'Gemfile'

      directory src do
        file 'Class.as.erb', "#{name}.as"
      end

      directory File.join(assets, skins) do
        file 'ProjectSprouts.png', 'ProjectSprouts.png'
      end unless no_assets

      directory lib unless no_lib
      directory bin

      default_project_files
    end
  end

  private

  def get_name
    @name.camel_case
  end
  
end

##
# Defined in the imaginary base class:
def default_project_files
  directory script do
    file 'generate', 'generate'
    file 'destroy', 'destroy'
    file 'console', 'console'
  end
end

##
# These directives ought to also be very easy to test.
#
class AppGeneratorTest
  include Sprout::GeneratorTestHelper

  context "a new generator" do

    setup do
      @fixture = File.join fixtures, 'generators'
      @generator = ProjectGenerator.new 
      @generator.path = @fixture
      @generator.name = 'SomeProject'
      @generator.execute
    end

    should_create_directory File.join(@fixture, 'SomeProject') do
      with_file 'rakefile.rb' do |content|
        assert_matches /SomeProject.as/, content
        assert_matches /SomeProjectRunner.as/, content
        assert_matches /SomeProject.swf/, content
      end
      should_create_directory 'script' do
        with_file 'generate'
        with_file 'destroy'
        with_file 'console'
      end
    end
  end

end

