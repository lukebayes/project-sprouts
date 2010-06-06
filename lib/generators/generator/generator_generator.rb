
module Sprout
  class GeneratorGenerator < Generator::Base

    add_param :lib, String, { :default => "lib" }
    add_param :generators, String, { :default => "generators" }
    add_param :test, String, { :default => "test" }
    add_param :unit, String, { :default => "unit" }
    add_param :bin, String, { :default => "bin" }
    add_param :extension, String, { :default => ".as" }
    
    def manifest
      directory bin do
        template "#{input.snake_case}", "generator_executable"
      end
      
      directory lib do
        directory generators do
          template "#{input.snake_case}_generator.rb", "generator_class.rb"
          directory "templates" do
            template "#{input.camel_case}#{extension}", "generator_template"
          end
        end
      end
      
      directory test do
        directory unit do
          template "#{input.snake_case}_generator_test.rb", "generator_test.rb"
        end
      end
      
    end

  end
end
