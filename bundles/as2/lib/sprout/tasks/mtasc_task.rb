=begin
Copyright (c) 2007 Pattern Park

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
=end

module Sprout # :nodoc:
  class MTASCError < StandardError #:nodoc:
  end

  # Compile sources using the Motion Twin ActionScript Compiler (MTASC[http://www.mtasc.org]).
  # 
  # Like standard Rake file tasks, the name given to the MTASCTask instance should be the
  # file that the task is epected to create. This value can be overridden in the configuration
  # block by using the -output parameter. 
  #
  #   mtasc 'bin/SomeProject.swf' do |t|
  #     t.main = true
  #     t.header = '800:600:24'
  #     t.input = 'src/SomeProject.as'
  #   end
  #
  # The above MTASCTask can be aliased for easier typing on the command line as follows:
  # 
  #   desc "Compile SomeProject.swf"
  #   task :compile => 'bin/SomeProject.swf'
  #
  # If the MTASCTask has a SWFMillTask as a prerequisite, it will automatically set that task output
  # as the value of the -swf paramter. Additionally, when MTASC pulls in an existing SWF file
  # you no longer need to define the -header parameter as it will use the dimensions and frame rate
  # found in the loaded SWF file. If the -header parameter is set, it will override
  # whatever settings are in the loaded SWF. Following is a short example:
  #
  #   swfmill 'bin/SomeProjectSkin.swf' do |t|
  #     t.input = 'assets/skin'
  #   end
  # 
  #   mtasc 'bin/SomeProject.swf' => 'bin/SomeProjectSkin.swf' do |t|
  #     t.main = true
  #     t.input = 'src/SomeProject.as'
  #   end
  #
  # Any LibraryTask instances that are added as prerequisites to the MTASCTask will be automatically
  # added to the class_path in the order they are declared as prerequisites.
  #
  # The following example will add the imaginary libraries :somelib, :otherlib and :yourlib to the class_path in that order.
  #
  #   library :yourlib
  #   library :otherlib
  #   library :somelib
  #
  #   mtasc 'bin/SomeProjectRunner.swf' => [:somelib, :otherlib, :yourlib] do |t|
  #     t.main = true
  #     t.header = '800:600:24'
  #     t.input = 'src/SomeProjectRunner.as'
  #   end
  #
  # <em>At this time, MTASC does not support libraries that are packaged as SWC files. We are considering 
  # adding support for SWC files in the near future, if you're interested in contributing to this 
  # feature, please let us know.</em>
  #
  class MTASCTask < ToolTask
    
    # Automatically include the installation MTASC 'std' library to the class_path. 
    attr_accessor :include_std

    def initialize_task # :nodoc:
      @include_std = false
      @default_gem_name = 'sprout-mtasc-tool'
      
      add_param(:cp, :paths) do |p|
        p.delimiter = ' '
        p.description =<<EOF
Add a directory path to the class path. This is the list of directories that MTASC will use to look for .as files. You can add as many class_path values as you like. This parameter is an Array, so be sure to append rather than overwrite.

Even though the official MTASC compiler accepts the +cp+ paramter, we have aliased it as +class_path+, you can use either name in your scripts.

  mtasc 'bin/SomeProject.swf' do |t|
    t.class_path << 'lib/somelib'
    t.class_path << 'lib/otherlib'
    # The following is not correct:
    # t.class_path = 'lib/somelib'
  end

EOF
      end

      add_param_alias(:class_path, :cp)

      add_param(:exclude, :file) do |p|
        p.delimiter = ' '
        p.description = "Exclude code generation of classes listed in specified file (format is one full class path per line)."
      end

      add_param(:frame, :number) do |p|
        p.delimiter = ' '
        p.description = "Export AS2 classes into target frame of swf."
      end

      add_param(:group, :boolean) do |p|
        p.hidden_value = true
        p.description = "Merge classes into one single clip (this will reduce SWF size but might cause some problems if you're using -keep or -mx)."
      end

      add_param(:header, :string) do |p|
        p.delimiter = ' '
        p.description = "width:height:fps:bgcolor: Create a new swf containing only compiled code and using provided header informations. bgcolor is optional and should be 6 digits hexadecimal value."
      end

      add_param(:infer, :boolean) do |p|
        p.hidden_value = true
        p.description = "Add type inference for initialized local variables."
      end

      add_param(:keep, :boolean) do |p|
        p.hidden_value = true
        p.description = "Keep AS2 classes compiled by MCC into the SWF (this could cause some classes to be present two times if also compiled with MTASC)."
      end

      add_param(:main, :boolean) do |p|
        p.hidden_value = true
        p.description = "Will automaticaly call static function main once all classes are registered."
      end

      add_param(:msvc, :boolean) do |p|
        p.hidden_value = true
        p.description = "Use Microsoft Visual Studio errors style formating instead of Java style (for file names and line numbers)."
      end

      add_param(:mx, :boolean) do |p|
        p.hidden_value  = true
        p.description   = "Use precompiled MX classes (see section on V2 components below)."
      end

      add_param(:out, :file) do |p|
        p.delimiter     = ' '
        p.description   = "The SWF file that should be generated, use only in addition to the -swf parameter if you want to generate a separate SWF from the one being loaded"
      end

      add_param(:pack, :paths) do |p|
        p.description = "Compile all the files contained in specified package - not recursively (eg to compile files in c:\flash\code\my\app do mtasc -cp c:\flash\code -pack my/app)."
      end

      add_param(:strict, :boolean) do |p|
        p.hidden_value = true
        p.description = "Use strict compilation mode which require that all variables are explicitely typed."
      end

      add_param(:swf, :file) do |p|
        p.delimiter = ' '
        p.required = true
        p.description =<<EOF
Specify the swf that should be generated, OR the input SWF which contains assets.

If this parameter is not set, the MTASCTask will do the following:
* Iterate over it's prerequisites and set the -swf parameter to the output of the first SWFMillTask found
* If no SWFMillTask instances are in this task prerequisites and the -swf parameter has not been set, it will be set to the same as the -out parameter
EOF
      end

      add_param(:trace, :string) do |p|
        p.delimiter = ' '
        p.description = "Specify a custom trace function. (see Trace Facilities), or no disable all the traces."
      end

      add_param(:version, :number) do |p|
        p.delimiter = ' '
        p.description = "Specify SWF version : 6 to generate Player 6r89 compatible SWF or 8 to access Flash8 features."
      end

      add_param(:v, :boolean) do |p|
        p.hidden_value = true
        p.description = "Activate verbose mode, printing some additional information about compiling process. This parameter has been aliased as +verbose+"
      end
      
      add_param_alias(:verbose, :v)

      add_param(:wimp, :boolean) do |p|
        p.hidden_value = true
        p.description = "Adds warnings for import statements that are not used in the file."
      end

      # This must be the last item in this list
      add_param(:input, :file) do |p|
        p.hidden_name = true
        p.required = true
        p.description = "Main source file to send compiler"
      end

      self.out = name.to_s.dup
    end

    def define # :nodoc:
      super
      resolve_skin
      self.swf = out unless swf
      CLEAN.add(out)
      
      # If we're on Linux, we need to manually reference
      # the standard library.
      # For more Info: http://code.google.com/p/projectsprouts/issues/detail?id=88
      @include_std = true if RUBY_PLATFORM =~ /linux/i

      if(@include_std)
        # Don't inject magic/fragile version numbers or platforms here
        files = Dir.glob(Sprout.sprout_cache + '/sprout-mtasc-tool-.*/archive/std/')
        files.each do |file|
          class_path << file
        end
      end
    end

    protected
    
    # Iterate over prerequisites until you find the first SWFMillTask
    # instance, and set self.swf = instance.output so that the skin
    # gets compiled in.
    def resolve_skin
      prerequisites.each do |prereq|
        instance = Rake::application[prereq]
        if(instance.is_a?(SWFMillTask))
          self.swf = instance.output
          break
        end
      end
    end

    # Handle prerequisite libraries by adding them to the source path
    def resolve_library(library_task)
      #TODO: Add support for libraries that don't get
      # copied into the project
      path = library_task.project_path
      if(path.match(/.swc$/))
        raise MTASCError.new("MTASC doesn't support SWC libraries, but this should be relatively easy to implement. Please let us know if you're interested in this feature!")
      else
        class_path << library_task.project_path
      end
    end
    
  end
end

def mtasc(args, &block)
  Sprout::MTASCTask.define_task(args, &block)
end
