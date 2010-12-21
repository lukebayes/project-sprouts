
module Sprout
  class GeneratorGenerator < Generator::Base

    ##
    # The default module that classes will be added
    # to.
    add_param :namespace, String, { :default  => ''}

    ##
    # The name of the folder where external libraries
    # will be installed.
    add_param :lib, String, { :default => 'lib' }

    ##
    # The name of the folder where custom generators and templates
    # will be found.
    add_param :generators, String, { :default => 'generators' }

    ##
    # The name of the folder where tests should be generated.
    add_param :test, String, { :default => 'test' }

    ##
    # The name of the child folder of the test folder where 
    # unit tests should be generated.
    add_param :unit, String, { :default => 'unit' }

    ##
    # The name of the child folder of the test folder where
    # fixtures should be generated.
    add_param :fixtures, String, { :default => 'fixtures' }

    ##
    # The name of the folder where external source code
    # should be placed.
    add_param :vendor, String, { :default => 'vendor' }

    ##
    # The name of the folder where binary or executable
    # artifacts should be created by compiler tasks.
    add_param :bin, String, { :default => 'bin' }

    ##
    # The default (primary) file extension for generated source
    # files. This should hint at the project type.
    add_param :extension, String, { :default => '.as' }

    def manifest  
      directory bin do
        template "#{input.snake_case}", "generator_executable"
      end

      directory lib do
        #We need to add a folder with the same name as the module to be used in order to faux namespace our generators to avoid collisions from super classes
        directory namespace do
          directory generators do
            template "#{input.snake_case}_generator.rb", "generator_class.rb"
            directory "templates" do
              template "#{input.camel_case}#{extension}", "generator_template"
            end
          end
        end
      end

      directory test do
        directory unit do
          template "#{input.snake_case}_generator_test.rb", "generator_test.rb"
          template "test_helper.rb", "generator_test_helper.rb"
        end
        directory fixtures do
          directory "generators"
        end
      end
      
      #This should actually be moved to the library generator
      #directory vendor

    end

  end
end
