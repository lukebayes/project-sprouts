require 'sprout/tasks/swfmill_input_task'

module Sprout
  
  class SWFMillError < StandardError #:nodoc:
  end

  # Compile a set of assets (pngs, gifs, jpegs, mp3s, fonts, etc)
  # into a library swf using SWFMill[http://www.swfmill.org].
  #
  # The resulting SWF file can be a Flash Player 6, 7 or 8 file format
  # and is appropriately used as asset input for MTASC or MXMLC compilation.
  #
  # This task simplifies SWFMill usage so that you can essentially
  # point it at a directory of images, set the task as a prerequisite
  # for an MTASCTask or an MXMLCTask, and have them self-configure
  # to include the output.
  #
  # A simple example is as follows:
  #
  #   swfmill 'assets/skins/SomeProjectSkin.swf' do |t|
  #     t.input = 'assets/skins/SomeProjectSkin'
  #   end
  #
  class SWFMillTask < ToolTask
    
    def initialize_task
      @default_gem_name = 'sprout-swfmill-tool'
      
      add_param(:simple, :boolean) do |p|
        p.value = true
        p.hidden_value = true
        p.prefix = ''
        p.description = "Set the SWFMill simple flag. This setting will determine what kind of xml document the compiler expects. Unless you really know what you're doing with SWFMill, this setting will usually be left alone."
      end
      
      add_param(:input, :string) do |p|
        p.hidden_name = true
        p.description =<<EOF
The input can be one of the following
 * SWFMill XML document: Create and manually manage an input file as described at http://www.swfmill.org
 * Directory: if you point at a directory, this task will automatically include all files found forward of that directory. As it descends into child directories, the items found will be exposed in the library using period delimiters as follows:

The file:
  yourcompany/yourproject/SomeFile.png
Will be available in the compiled swf with a linkage identifier of:
  yourcompany.yourproject.SomeFile
EOF
      end

      add_param(:output, :file) do |p|
        p.hidden_name = true
        p.description = "The output parameter should not be set from outside of this task, the output file should be the task name"
      end

      add_param(:template, :file) do |p|
        p.description = "An ERB template to send to the generated SWFMillInputTask. This template can be used to generate an XML input document based on the contents of a directory. If no template is provided, one will be created for you after the first run, and once created, you can configure it however you wish."
      end

      self.output = name.to_s
    end

    def define # :nodoc:
      raise SWFMillError.new("The SWFMillTask should be given a SWF file as a task name instead of '#{name}'") unless output.match(/\.swf$/)

      CLEAN.add(output)

      # Respond to input parameter configuration
      if(File.directory?(input))
        swfmill_input input_task_name do |t|
          t.input = input
          self.input = t.output # not a typo!
        end
        prerequisites << input_task_name
        simple = true
      end

      if(input.match(/.xml$/))
        @simple = true
      end
    end
    
    private
    
    def input_task_name
      @input_task_name ||= create_input_task_name
    end
    
    def create_input_task_name
      input_task_name = name.to_s.dup
      input_task_name.gsub!(/.swf$/, 'Input.xml')
      return input_task_name
    end

  end
end

def swfmill(args, &block)
  Sprout::SWFMillTask.define_task(args, &block)
end
