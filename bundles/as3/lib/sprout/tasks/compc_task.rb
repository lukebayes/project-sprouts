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

module Sprout
  class COMPCError < StandardError #:nodoc:
  end
  class ExecutionError < StandardError #:nodoc:
  end
  
  # The COMPCTask will emit SWC files that are usually used to easily distribute and include
  # shared functionality.
  #
  # This task represents a superset of the features available to the MXMLCTask.
  #
  # A simple COMPC instance is as follows:
  #
  #   compc 'bin/SomeLibrary.swc' do |t|
  #     t.input = 'SomeLibrary' # Class name, not file name
  #     t.source_path << 'src'
  #     t.source_path << 'test'
  #   end
  # 
  class COMPCTask < MXMLCTask

    def initialize_task
      super
      @default_gem_name = 'sprout-flex3sdk-tool'
      @default_gem_path = 'bin/compc'

      add_param(:directory, :boolean) do |p|
        p.hidden_value = true
        p.description =<<EOF
Outputs the SWC file in an open directory format rather than a SWC file. You use this option with the output option to specify a destination directory, as the following example shows:
compc -directory -output destination_directory

You use this option when you create RSLs. For more information, see Using Runtime Shared Libraries (http://livedocs.adobe.com/flex/201/html/rsl_124_1.html#168690).
EOF
      end

      add_param(:include_classes, :symbols) do |p|
        p.to_shell_proc = Proc.new {|param|
          return if(param.value.nil?)
          
          if(param.value.is_a? Array)
            "-include-classes #{param.value.join(' ')}"
          else
            "-include-classes #{param.value}"
          end
        }
        p.description =<<EOF
Specifies classes to include in the SWC file. You provide the class name (for example, MyClass) rather than the file name (for example, MyClass.as) to the file for this option. As a result, all classes specified with this option must be in the compiler's source path. You specify this by using the source-path compiler option.

You can use packaged and unpackaged classes. To use components in namespaces, use the include-namespaces option.

If the components are in packages, ensure that you use dot-notation rather than slashes to separate package levels.

This is the default option for the component compiler.
EOF
      end

      add_param_alias(:ic, :include_classes)

      add_param(:include_file, :files) do |p|
        p.description =<<EOF
Adds the file to the SWC file. This option does not embed files inside the library.swf file. This is useful for skinning and theming, where you want to add non-compiled files that can be referenced in a style sheet or embedded as assets in MXML files.

If you use the [Embed] syntax to add a resource to your application, you are not required to use this option to also link it into the SWC file.

For more information, see Adding nonsource classes (http://livedocs.adobe.com/flex/201/html/compilers_123_39.html#158900).
EOF
      end

      add_param(:include_lookup_only, :boolean) do |p|
        p.description =<<EOF
EOF
      end

      add_param(:include_namespaces, :urls) do |p|
        p.description =<<EOF
Specifies namespace-style components in the SWC file. You specify a list of URIs to include in the SWC file. The uri argument must already be defined with the namespace option.

To use components in packages, use the include-classes option.
EOF
      end

      add_param(:include_resource_bundles, :files) do |p|
        p.description =<<EOF
Specifies the resource bundles to include in this SWC file. All resource bundles specified with this option must be in the compiler's source path. You specify this using the source-path compiler option.

For more information on using resource bundles, see Localizing Flex Applications (http://livedocs.adobe.com/flex/201/html/l10n_076_1.html#129288) in Flex 2 Developer's Guide.
EOF
      end

      add_param(:include_sources, :paths) do |p|
        p.preprocessable = true
        p.description =<<EOF
Specifies classes or directories to add to the SWC file. When specifying classes, you specify the path to the class file (for example, MyClass.as) rather than the class name itself (for example, MyClass). This lets you add classes to the SWC file that are not in the source path. In general, though, use the include-classes option, which lets you add classes that are in the source path.

If you specify a directory, this option includes all files with an MXML or AS extension, and ignores all other files.
EOF
      end

      add_param(:namespace, :string) do |p|
        p.description =<<EOF
Not sure about this option, it was in the CLI help, but not documented on the Adobe site
EOF
      end

      # Move the input param to the end of the stack:
      input_param = nil
      params.each_index do |index|
        param = params[index]
        if(param.name == 'input')
          input_param = param
          params.slice!(index, 1)
          break
        end
      end
      params << input_param unless input_param.nil?

    end

  end
end

def compc(args, &block)
  Sprout::COMPCTask.define_task(args, &block)
end

