
module Sprout
  class LibraryGenerator < Generator::Base
    #TODO: The library generator needs to:
    #Create the outer folder with the input passed in as the library name if no outer folder exists
    #Create a lib dir and put the file generated from the library.rb template in it
    #Create a vendor folder
    
    ##
    # Set the version string to use.
    add_param :version, String, { :default => '0.0.1' }

    def manifest
      template "#{input.snake_case}.gemspec", 'library.gemspec'
      template "#{input.snake_case}.rb", 'library.erb'
    end

  end
end

