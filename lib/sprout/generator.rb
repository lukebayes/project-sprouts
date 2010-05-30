module Sprout

  class Generator
    include Executable

    ##
    # The name of the application or component
    add_param :name, String, { :hidden_name => true, :required => true }

    def default_project_files
      directory script do
        file 'generate', 'generate'
        file 'destroy', 'destroy'
        file 'console', 'console'
      end
    end

    def execute
      #puts ">> execute with: #{camel_cased_name}"
    end

    protected

    def camel_cased_name
      self.name.camel_case
    end
  end
end

