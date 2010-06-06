
module Sprout
  class LibraryGenerator < Generator::Base

    ##
    # Set the version string to use.
    add_param :version, String, { :default => '0.0.1' }

    def manifest
      template "#{input.snake_case}.gemspec", 'library.gemspec'
      template "#{input.snake_case}.rb", 'library.rb'
    end

  end
end

