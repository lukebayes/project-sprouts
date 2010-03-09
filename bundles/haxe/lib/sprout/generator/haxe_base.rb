
module Sprout
  module Generator #:nodoc:
    
    # The NamedBase is a good default base class for ActionScript class Generators.
    # This class will accept the first command line argument and create
    # many helpful properties for concrete generators to use.
    #
    # Can accept class names in following formats:
    #   * src/package/package/ClassName.hx
    #   * test/package/package/ClassName.hx
    #   * package/package/ClassName
    #   * package.package.ClassName
    #
    # Regardless of which format the name was sent in, the helper
    # methods should provide valid results
    #
    class HaxeBase < NamedBase

      # Filesystem path to the TestCase file
      def full_test_case_path
        @full_test_case_path ||= File.join(full_test_dir, test_case_name + '.hx')
      end

      # Glob that is used to search for test cases and build 
      # up the test suites
      def test_glob
        return @test_glob ||= "**/**/?*Test.hx"
      end
      
      # Transform a file name in the source or test path
      # to a fully-qualified class name
      def actionscript_file_to_class_name(file)
        name = file.dup
        name.gsub!(/^#{Dir.pwd}\//, '')
        name.gsub!(/^#{test_dir}\//, '')
        name.gsub!(/^#{src_dir}\//, '')
        name.gsub!(/.hx$/, '')
        name.gsub!(/#{File::SEPARATOR}/, '.')
        return name
      end
      
      protected

      def model
        @model ||= ProjectModel.instance
      end

      def assign_names!(name)
        # trim file name suffix in case it was submitted
        name.gsub!(/\//, '.')
        name.gsub!(/\.hx$/, '')
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
        @class_file = @full_class_name.split('.').join(File::SEPARATOR) + '.hx'
        @class_dir = File.dirname(@class_file)
        if(@class_dir == '.')
          @class_dir = ''
        end
      end
    end
  end
end
