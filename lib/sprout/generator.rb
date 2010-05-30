module Sprout

  class Generator
    include Executable

    ##
    # The name of the application or component
    add_param :name, String, { :reader => :get_name, :hidden_name => true, :required => true }

    def default_project_files
      directory script do
        file 'generate', 'generate'
        file 'destroy', 'destroy'
        file 'console', 'console'
      end
    end

    def execute
      #puts ">> execute with: #{name}"
    end

    protected

    def get_name
      @name.camel_case
    end
  end
end

