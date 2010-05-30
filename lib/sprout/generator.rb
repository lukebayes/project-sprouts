
module Sprout

  module Generator
    include Executable

    ##
    # The name of the application or component
    add_param :name, String, { :reader => :get_name }

    def default_project_files
      directory script do
        file 'generate', 'generate'
        file 'destroy', 'destroy'
        file 'console', 'console'
      end
    end

    protected

    def get_name
      @name.camel_case
    end
  end
end

