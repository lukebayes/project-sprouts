
module Sprout
  class GeneratorGenerator < Generator::Base

    add_param :namespace, String, { :default  => ''}
    add_param :lib, String, { :default => 'lib' }
    add_param :generators, String, { :default => 'generators' }
    add_param :test, String, { :default => 'test' }
    add_param :unit, String, { :default => 'unit' }
    add_param :fixtures, String, { :default => 'fixtures' }
    add_param :vendor, String, { :default => 'vendor' }    
    add_param :bin, String, { :default => 'bin' }
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
