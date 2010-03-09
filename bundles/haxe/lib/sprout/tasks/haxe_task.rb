sprout 'as3'

module Sprout #:nodoc:
  
  class TaskParam #:nodoc:

    def delimiter
      @delimiter ||= ' '
    end
    
  end
  
  class StringsParam #:nodoc:
    def delimiter
      @delimiter ||= ' '
    end
  end

  class HaxeError < StandardError #:nodoc:
  end

  #
  # Rake task wrapper for the HaXe Compiler.
  #
  # Some HaXe compiler params have been aliased to
  # provide a more consistent experience with Adobe
  # compilers.
  #
  # An example usage follows:
  #
  #   desc 'Compile output'
  #    haxe :compile do |t|
  #      t.input = input
  #      t.output = output
  #      t.source_path << 'src'
  #      t.swf_header '800:500:40:ffffff'
  #    end
  #

  class HaxeTask < ToolTask
    
    def initialize_task
      
      add_param(:cp, :paths) do |p|
        p.description = 'add a directory to find source files'
      end
    
      add_param_alias(:class_path, :cp) # Long form
      add_param_alias(:source_path, :cp) # Adobe consistency
    
      add_param(:js, :file) do |p|
        p.description = 'compile code to JavaScript file'
      end
    
      add_param(:swf, :file) do |p|
        p.description = 'compile code to Flash SWF file'
      end
    
      add_param(:swf9, :file) do |p|
        p.description = 'compile code to Flash9 SWF file'
      end
    
      add_param_alias :output, :swf9
    
      add_param(:as3, :path) do |p|
        p.description = 'generate AS3 code into target directory'
      end
    
      add_param(:neko, :file) do |p|
        p.description = 'compile code to Neko Binary'
      end
    
      add_param(:php, :path) do |p|
        p.description = 'generate PHP code into target directory'
      end
    
      add_param(:xml, :file) do |p|
        p.description = 'generate XML types description'
      end
    
      add_param(:main, :string) do |p|
        p.description = 'Startup class with static main function. This should not be a file reference, but the fully qualified class name.'
      end
    
      add_param_alias :input, :main
    
      add_param(:libs, :strings) do |p|
        p.description = '<library[:version]> use an haxelib library'
      end
    
      add_param(:conditional, :string) do |p|
        p.description = 'define a conditional compilation flag'
      end
    
      add_param_alias :d, :conditional
    
      add_param(:verbose, :boolean) do |p|
        p.hidden_value = true
        p.description = 'turn on verbose mode'
      end
    
      add_param_alias :v, :verbose
    
      add_param(:debug, :boolean) do |p|
        p.hidden_value = true
        p.description = 'add debug informations to the compiled code'
      end
    
      add_param(:swf_version, :number) do |p|
        p.description = 'change the SWF version (6 to 10)'
      end
    
      add_param(:swf_header, :string) do |p|
        p.description = 'define SWF header (width:height:fps:color)'
      end
    
      # TODO: Can this be used more than once?
      add_param(:swf_lib, :file) do |p|
        p.description = 'add the SWF library to the compiled SWF'
      end
    
      add_param(:x, :file) do |p|
        p.description = 'shortcut for compiling and executing a neko file'
      end
    
      add_param(:resource, :file) do |p|
        p.description = 'add a named resource file'
      end
    
      add_param(:exclude, :file) do |p|
        p.description = "don't generate code for classes listed in this file"
      end
    
      add_param(:prompt, :boolean) do |p|
        p.hidden_value = true
        p.description = 'prompt on error'
      end
    
      add_param(:cmd, :string) do |p|
        p.description = 'run the specified command after successful compilation'
      end
    
      add_param(:flash_strict, :boolean) do |p|
        p.prefix = '--'
        p.hidden_value = true
        p.description = 'more type strict flash API'
      end
    
      add_param(:no_traces, :boolean) do |p|
        p.prefix = '--'
        p.hidden_value = true
        p.description = "don't compile trace calls in the program"
      end
    
      add_param(:flash_use_stage, :boolean) do |p|
        p.prefix = '--'
        p.hidden_value = true
        p.description = 'place objects found on the stage of the SWF lib'
      end
    
      add_param(:neko_source, :boolean) do |p|
        p.hidden_value = true
        p.description = 'keep generated neko source'
      end
    
      add_param(:gen_hx_classes, :file) do |p|
        p.description = 'generate hx headers from SWF9 file'
      end
    
      add_param(:next, :boolean) do |p|
        p.prefix = '--'
        p.hidden_value = true
        p.description = 'separate several haxe compilations'
      end
    
      add_param(:display, :boolean) do |p|
        p.prefix = '--'
        p.hidden_value = true
        p.description = 'display code tips'
      end
    
      add_param(:no_output, :boolean) do |p|
        p.prefix = '--'
        p.hidden_value = true
        p.description = 'compiles but does not generate any file'
      end
    
      add_param(:times, :boolean) do |p|
        p.prefix = '--'
        p.hidden_value = true
        p.description = 'measure compilation times'
      end
    
      add_param(:no_inline, :boolean) do |p|
        p.prefix = '--'
        p.hidden_value = true
        p.description = 'disable inlining'
      end
    
      add_param(:no_opt, :boolean) do |p|
        p.prefix = '--'
        p.hidden_value = true
        p.description = 'disable code optimizations'
      end
    
      add_param(:php_front, :file) do |p|
        p.prefix = '--'
        p.description = 'select the name for the php front file'
      end
    
      add_param(:remap, :string) do |p|
        p.prefix = '--'
        p.description = '<package:target> remap a package to another one'
      end
    end
    
    def define # :nodoc:
      super

      if(!output)
        if(name.match(/.swf/) || name.match(/swc/))
          self.output = name
        end
      end
      
      if(main && File.exists?(main))
        cp << File.dirname(main)
      end
      
      CLEAN.add(output)

      source_path.uniq!
      # param_hash[:source_path].value = clean_nested_source_paths(source_path)

      self
    end
    
    def execute(*args)
      start = Time.now
      User.execute('haxe', to_shell)
      puts ">> #{(File.size(output) / 1000)} kb compiled in #{(Time.now - start)} seconds"
    end
    
    private
    
    # def clean_nested_source_paths(paths)
    #   results = []
    #   paths.each do |path|
    #     if(check_nested_source_path(results, path))
    #       results << path
    #     end
    #   end
    #   return results
    # end
    # 
    # def check_nested_source_path(array, path)
    #   array.each_index do |index|
    #     item = array[index]
    #     if(item =~ /^#{path}/)
    #       array.slice!(index, 1)
    #     elsif(path =~ /^#{item}/)
    #       return false
    #     end
    #   end
    #   return true
    # end

  end
end

# Helper method for definining and accessing MXMLCTask instances in a rakefile
def haxe(args, &block)
  Sprout::HaxeTask.define_task(args, &block)
end
