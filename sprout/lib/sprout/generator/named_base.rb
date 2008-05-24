
module Sprout
  module Generator #:nodoc:
    
    class NamedBaseError < StandardError #:nodoc:
    end
    
    # The NamedBase is a good default base class for ActionScript class Generators.
    # This class will accept the first command line argument and create
    # many helpful properties for concrete generators to use.
    #
    # Can accept class names in following formats:
    #   * src/package/package/ClassName.as
    #   * test/package/package/ClassName.as
    #   * package/package/ClassName
    #   * package.package.ClassName
    #
    # Regardless of which format the name was sent in, the helper
    # methods should provide valid results
    #
    class NamedBase < Rails::Generator::Base

      # Fully qualified class named including package name like 'flash.display.Sprite'
      attr_reader :full_class_name
      # Path to the class file relative to your src_dir like 'flash/display/Sprite.as'
      attr_reader :class_file
      # The directory that contains the file, relative to your src_dir like 'flash/diplay'
      attr_reader :class_dir
      # The unqualified name of the class like 'Sprite'
      attr_reader :class_name
      # The package name of the class like 'flash.display'
      attr_reader :package_name

      def initialize(runtime_args, runtime_options = {})
        super

        rakefile = Sprout.project_rakefile
        if(rakefile && File.exists?(rakefile))
           load rakefile
        end
        @model = ProjectModel.instance

        # Had to stop throwing on no args because the suite generator does
        # not require the user to send in a class name....
        #usage("Final argument must be a name parameter") if runtime_args.empty?
        @args = runtime_args.dup
        assign_names! @args.shift
      end

      # Quick access to the source directory identified by your project model
      def src_dir
        return model.src_dir
      end
      
      # Quick access to the test directory identified by your project model
      def test_dir
        return model.test_dir
      end
      
      # Quick access to the library directory identified by your project model
      def lib_dir
        return model.lib_dir
      end
      
      # The path to your project. This will either be the directory from which
      # the sprout gem was executed, or the nearest ancestor directory that
      # contains a properly named rakefile.
      def project_path
        return model.project_path
      end
      
      # The project_name that was either sent to the sprout gem or 
      # defined in your rakefile project model
      def project_name
        @project_name ||= (Sprout.project_name || model.project_name)
      end
      
      # The technology language that is stored in your project model usually (as2 or as3)
      def language
        return model.language
      end

      # Name of possible test case for this class_name
      def test_case_name
        @test_case_name ||= class_name + 'Test'
      end
      
      # Full name of the possible test case for this class_name
      def full_test_case_name
        full_class_name + 'Test'
      end

      # Full path to the parent directory that contains the class
      # like 'src/flash/display' for flash.display.Sprite class.
      def full_class_dir
        @full_class_dir ||= File.join(src_dir, class_dir)
        # pull trailing slash for classes in the root package
        @full_class_dir.gsub!(/\/$/, '')
        @full_class_dir
      end

      # Full path to the class file from your project_path like 'src/flash/display/Sprite.as'
      def full_class_path
        @full_class_path ||= File.join(src_dir, class_file)
      end

      # Filesystem path to the folder that contains the TestCase file
      def full_test_dir
        @full_test_dir ||= full_class_dir.gsub(src_dir, test_dir)
      end
      
      # Filesystem path to the TestCase file
      def full_test_case_path
        @full_test_case_path ||= File.join(full_test_dir, test_case_name + '.as')
      end

      # Path to the in-project generate script
      # pulled out for DOS branching
      def generate_script_path
        usr = User.new
        if(usr.is_a?(WinUser) && !usr.is_a?(CygwinUser))
          return File.join(class_name, 'script', "generate.rb")
        else
          return File.join(class_name, 'script', "generate")
        end
      end
      
      def instance_name
        name = class_name.dup;
        char = name[0, 1]
        name[0, 1] = char.downcase
        if(name.size > 10)
          name = 'instance'
        end
        return name
      end

      # Will return whether the user originally requested a class name
      # that looks like a test case (e.g., name.match(/Test$/) )
      def user_requested_test
        @user_requested_test ||= false
      end

      # Glob that is used to search for test cases and build 
      # up the test suites
      def test_glob
        return @test_glob ||= '**/**/*Test.as'
      end
      
      def test_glob=(glob)
        @test_glob = glob
      end

      # Collection of all test case files either assigned or found
      # using the test_glob as provided.
      def test_cases
        @test_cases ||= Dir.glob(test_dir + test_glob)
      end
      
      def test_cases=(collection)
        @test_cases = collection
      end
      
      # Get the list of test_cases (which are files) as a 
      # list of fully qualified class names
      def test_case_classes
        @test_case_classes = self.test_cases.dup
        @test_case_classes.collect! do |file|
          actionscript_file_to_class_name(file)
        end
        @test_case_classes
      end

      # Transform a file name in the source or test path
      # to a fully-qualified class name
      def actionscript_file_to_class_name(file)
        name = file.dup
        name.gsub!(/^#{Dir.pwd}\//, '')
        name.gsub!(/^#{test_dir}\//, '')
        name.gsub!(/^#{src_dir}\//, '')
        name.gsub!(/.as$/, '')
        name.gsub!(/#{File::SEPARATOR}/, '.')
        return name
      end
      
      protected

      def banner
        "Usage: #{$0} [options] packagename.ClassName"
      end

      def model
        @model ||= ProjectModel.instance
      end

      def assign_names!(name)
        # trim file name suffix in case it was submitted
        name.gsub!(/\//, '.')
        name.gsub!(/\.as$/, '')
        name.gsub!(/\.mxml$/, '')
        if(model)
          # Pull leading src_dir from class name if submitted
          name.gsub!(/^#{src_dir}\./, '')
          name.gsub!(/^#{test_dir}\./, '')
        end

        if(name.match(/Test$/))
          @user_requested_test = true
          name = name.gsub(/Test$/, '')
        end
        if(name.match(/^I/) || name.match(/able$/))
          @user_requested_interface = true
        end

        @full_class_name = name
        parts = name.split('.')
        @class_name = parts.pop
        @package_name = parts.join('.')
        @class_file = @full_class_name.split('.').join(File::SEPARATOR) + '.as'
        @class_dir = File.dirname(@class_file)
        if(@class_dir == '.')
          @class_dir = ''
        end
      end
    end
  end
end
