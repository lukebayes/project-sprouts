
module Sprout
  class RubyGenerator < Sprout::Generator::Base

    ##
    # The 3-part version for the new Ruby application.
    add_param :version, String, { :default => '0.0.0.pre' }

    ##
    # The name of the 'lib' directory - where your Ruby
    # files will be located.
    add_param :lib, String, { :default => 'lib' }

    ##
    # The name of the 'test' directory - where all tests
    # and fixtures will be located.
    add_param :test, String, { :default => 'test' }

    ##
    # The name of the 'unit' directory - where unit tests
    # will be located.
    add_param :unit, String, { :default => 'unit' }

    ##
    # The name of the 'fixtures' directory - where test
    # fixtures will be located.
    add_param :fixtures, String, { :default => 'fixtures' }

    ##
    # The name of the bin directory - where executables
    # will be located.
    add_param :bin, String, { :default => 'bin' }

    def manifest
      snake = input.snake_case

      directory snake do
        template 'Gemfile', 'ruby_gemfile'
        template 'Rakefile', 'ruby_rakefile'
        template "#{input.snake_case}.gemspec", 'ruby_gemspec'

        directory lib do
          template "#{snake}.rb", 'ruby_input.rb'
          directory snake do
            template 'base.rb', 'ruby_base.rb'
          end
        end

        directory test do
          directory fixtures
          directory unit do
            template "#{input.snake_case}_test.rb", 'ruby_test_case.rb'
          end
          template 'test_helper.rb', 'ruby_test_helper.rb'
        end

        directory bin do
          template input.dash_case, 'ruby_executable'
        end
      end
    end
  end
end

