module Sprout
  #
  # The ADL Task provides Rake support for the adl, Adobe Debug Launcher command.
  # http://livedocs.adobe.com/flex/3/html/help.html?content=CommandLineTools_4.html#1031914
  #
  # The following example can be pasted in a file named 'rakefile.rb':
  #
  #   # Create an ADL task named :run dependent upon the swf that it is using for the window content
  #   adl :run => 'SomeProject.swf' do |t|
  #     t.root_directory = model.project_path
  #     t.application_descriptor = "#{model.src_dir}/TestProj-app.xml"
  #   end
  #
  class ADLTask < ToolTask

    def initialize_task
      super
      @default_gem_name = 'sprout-flex3sdk-tool'
      @default_gem_path = 'bin/adl'

      add_param(:runtime, :file) do |p|
        p.delimiter = " "
        p.description = <<-DESC
        Specifies the directory containing the runtime to use. If not 
        specified, the runtime directory in the same SDK as the ADL program
        will be used. If you move ADL out of its SDK folder, then you must 
        specify the runtime directory. On Windows, specify the directory 
        containing the Adobe AIR directory. On Mac OSX, specify the directory 
        containing Adobe AIR.framework.
        DESC
      end

      add_param(:nodebug, :boolean) do |p|
        p.hidden_value = true
        p.description = <<-DESC
        Turns off debugging support. If used, the application process cannot 
        connect to the Flash debugger and dialogs for unhandled exceptions are
        suppressed. 
        
        Trace statements still print to the console window. Turning off 
        debugging allows your application to run a little faster and also 
        emulates the execution mode of an installed application more closely.
        DESC
      end
      
      add_param(:pubid, :string) do |p|
        p.delimiter = " "
        p.description = <<-DESC
        Assigns the specified value as the publisher ID of the AIR application 
        for this run. Specifying a temporary publisher ID allows you to test 
        features of an AIR application, such as communicating over a local 
        connection, that use the publisher ID to help uniquely identify an 
        application. 
        
        The final publisher ID is determined by the digital certificate used to 
        sign the AIR installation file.
        DESC
      end

      add_param(:application_descriptor, :file) do |p|
        p.hidden_name = true
        p.required = true
        p.description = "The application descriptor file."
      end
      
      add_param(:root_directory, :file) do |p|
        p.hidden_name = true
        p.required = true
        p.description = <<-DESC
        The root directory of the application to run. If not 
        specified, the directory containing the application 
        descriptor file is used.
        DESC
      end
      
      add_param(:arguments, :string) do |p|
        p.shell_name = "--"
        p.delimiter = " "
        p.description = <<-DESC
        Passed to the application as command-line arguments.
        DESC
      end
            
    end
        
  end
end

# Helper method for definining and accessing ADLTask instances in a rakefile
def adl(args, &block)
  Sprout::ADLTask.define_task(args, &block)
end


