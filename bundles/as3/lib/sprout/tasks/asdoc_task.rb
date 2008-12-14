

module Sprout
  #
  # The AsDoc Task provides Rake support for the asdoc documentation engine.
  # If a MXMLCTask or COMPCTask are found as prerequisites
  # to the AsDoc task, AsDoc will inherit the source_path and library_path
  # from those tasks. You can also configure AsDoc normally if you wish.
  #
  # This configuration might look something like this:
  #
  #   # Create a remote library dependency on the corelib swc.
  #   library :corelib
  # 
  #   # Alias the compilation task with one that is easier to type
  #   # task :compile => 'SomeProject.swf'
  #
  # AsDoc tasks can be created and configured directly like any other rake task.
  #
  #   # Create a simple, standard asdoc task
  #   asdoc :doc do |t|
  #     t.source_path               << 'src'
  #     t.library_path              << 'lib/corelib.swc'
  #     t.doc_classes               = 'SomeProject'
  #     t.main_title                = 'Some Project Title'
  #     t.footer                    = 'This is the footer for your project docs'
  #   end
  #
  #   # Create an MXMLCTask named for the output file that it creates. This task depends on the
  #   # corelib library and will automatically add the corelib.swc to it's library_path
  #   mxmlc 'bin/SomeProject.swf' => :corelib do |t|
  #     t.input                     = 'src/SomeProject.as'
  #     t.default_size              = '800 600'
  #     t.default_background_color  = "#FFFFFF"
  #     t.source_path               << 'src'
  #     t.source_path               << 'lib/asunit'
  #     t.source_path               << 'test'
  #   end
  #
  #   desc "Generate documentation"
  #   asdoc :doc => 'bin/SomeProject.swf'
  #
  # This configuration will generate documentation in the relative path, 'doc', but only if
  # The contents of the documentation directory are older than the sources referenced by the compiler.
  #
  # For more information about using the asdoc command line compiler, check livedocs at:
  # http://livedocs.adobe.com/flex/201/html/wwhelp/wwhimpl/common/html/wwhelp.htm?context=LiveDocs_Book_Parts&file=asdoc_127_1.html
  # 
  class AsDocTask < ToolTask
    
    attr_accessor :use_fcsh # :nodoc:

    def initialize_task
      super
      @default_gem_name = 'sprout-flex3sdk-tool'
      @default_gem_path = 'bin/asdoc'

      add_param(:actionscript_file_encoding, :string) do |p|
        p.description = "Sets the file encoding for ActionScript files. For more information see: http://livedocs.adobe.com/flex/2/docs/00001503.html#149244"
      end

      add_param(:benchmark, :boolean) do |p|
        p.value = true
        p.show_on_false = true
        p.description = "Prints detailed compile times to the standard output. The default value is true."
      end

      add_param(:doc_classes, :strings) do |p|
        p.description =<<EOF
A list of classes to document. These classes must be in the source path. This is the default option.

This option works the same way as does the -include-classes option for the compc component compiler. For more information, see Using the component compiler (http://livedocs.adobe.com/flex/201/html/compilers_123_31.html#162910).
EOF
      end
    
      add_param(:doc_namespaces, :strings) do |p|
        p.description =<<EOF
A list of URIs whose classes should be documented. The classes must be in the source path.

You must include a URI and the location of the manifest file that defines the contents of this namespace.

This option works the same way as does the -include-namespaces option for the compc component compiler. For more information, see Using the component compiler. (http://livedocs.adobe.com/flex/201/html/compilers_123_31.html#162910)
EOF
      end

      add_param(:doc_sources, :paths) do |p|
        p.description =<<EOF
A list of files that should be documented. If a directory name is in the list, it is recursively searched.

This option works the same way as does the -include-sources option for the compc component compiler. For more information, see Using the component compiler (http://livedocs.adobe.com/flex/201/html/compilers_123_31.html#162910).
EOF
      end

      add_param(:exclude_classes, :strings) do |p|
        p.delimiter = '='
        p.description =<<EOF
A list of classes that should not be documented. You must specify individual class names. Alternatively, if the ASDoc comment for the class contains the @private tag, is not documented.
EOF
      end

      add_param(:exclude_dependencies, :boolean) do |p|
        p.description =<<EOF
Whether all dependencies found by the compiler are documented. If true, the dependencies of the input classes are not documented.

The default value is false.
EOF
      end

      add_param(:footer, :string) do |p|
        p.description =<<EOF
The text that appears at the bottom of the HTML pages in the output documentation.
EOF
      end

      add_param(:left_frameset_width, :number) do |p|
        p.description =<<EOF
An integer that changes the width of the left frameset of the documentation. You can change this size to accommodate the length of your package names.

The default value is 210 pixels.
EOF
      end

      add_param(:library_path, :files) do |p|
        p.description =<<EOF
Links SWC files to the resulting application SWF file. The compiler only links in those classes for the SWC file that are required.

The default value of the library-path option includes all SWC files in the libs directory and the current locale. These are required.

To point to individual classes or packages rather than entire SWC files, use the source-path option.

If you set the value of the library-path as an option of the command-line compiler, you must also explicitly add the framework.swc and locale SWC files. Your new entry is not appended to the library-path but replaces it.

You can use the += operator to append the new argument to the list of existing SWC files.

In a configuration file, you can set the append attribute of the library-path tag to true to indicate that the values should be appended to the library path rather than replace it.
EOF
      end

      add_param(:load_config, :file) do |p|
        p.description =<<EOF
Specifies the location of the configuration file that defines compiler options.

If you specify a configuration file, you can override individual options by setting them on the command line.

All relative paths in the configuration file are relative to the location of the configuration file itself.

Use the += operator to chain this configuration file to other configuration files.

For more information on using configuration files to provide options to the command-line compilers, see About configuration files (http://livedocs.adobe.com/flex/2/docs/00001490.html#138195).
EOF
      end

      add_param(:main_title, :string) do |p|
        p.description =<<EOF
The text that appears at the top of the HTML pages in the output documentation.

The default value is "API Documentation".
EOF
      end

      add_param(:namespace, :string) do |p|
        p.description =<<EOF
Not sure about this option, it was in the CLI help, but not documented on the Adobe site
EOF
      end

      add_param(:output, :path) do |p|
        p.value = 'doc'
        p.description =<<EOF
The output directory for the generated documentation. The default value is "doc".
EOF
      end

      add_param(:package, :string) do |p|
        p.description =<<EOF
The descriptions to use when describing a package in the documentation. You can specify more than one package option.

The following example adds two package descriptions to the output:
asdoc -doc-sources my_dir -output myDoc -package com.my.business "Contains business classes and interfaces" -package com.my.commands "Contains command base classes and interfaces"
EOF
      end

      add_param(:source_path, :paths) do |p|
        p.description =<<EOF
Adds directories or files to the source path. The Flex compiler searches directories in the source path for MXML or AS source files that are used in your Flex applications and includes those that are required at compile time.

You can use wildcards to include all files and subdirectories of a directory.

To link an entire library SWC file and not individual classes or directories, use the library-path option.

The source path is also used as the search path for the component compiler's include-classes and include-resource-bundles options.

You can also use the += operator to append the new argument to the list of existing source path entries.
EOF
      end

      add_param(:strict, :boolean) do |p|
        p.value = true
        p.show_on_false = true
        p.description =<<EOF
Prints undefined property and function calls; also performs compile-time type checking on assignments and options supplied to method calls.

The default value is true.

For more information about viewing warnings and errors, see Viewing warnings and errors (http://livedocs.adobe.com/flex/2/docs/00001517.html#182413).
EOF
      end

      add_param(:templates_path, :paths) do |p|
        p.description =<<EOF
The path to the ASDoc template directory. The default is the asdoc/templates directory in the ASDoc installation directory. This directory contains all the HTML, CSS, XSL, and image files used for generating the output.
EOF
      end

      add_param(:warnings, :boolean) do |p|
        p.description =<<EOF
Enables all warnings. Set to false to disable all warnings. This option overrides the warn-warning_type options.

The default value is true.
EOF
      end

      add_param(:window_title, :string) do |p|
        p.description =<<EOF
The text that appears in the browser window in the output documentation.

The default value is "API Documentation".
EOF
      end
    end

    def exclude_expressions
      @exclude_expressions ||= []
    end

    def define # :nodoc:
      apply_exclusions_from_expression unless @exclude_expressions.nil?

      super
      validate_templates
      CLEAN.add(output)
    end
    
    def prepare
      super
      prerequisite = nil
      @prerequisites.each do |req|
        prerequisite = @application[req]
        if(prerequisite.is_a?(MXMLCTask))
          prerequisite.source_path.each do |path|
            doc_sources << path
          end
          prerequisite.library_path.each do |path|
            library_path << path
          end
        end
      end
    end

    protected
    
    def validate_templates
      if(templates_path.size == 0)
        templates_dir = Sprout.get_executable(gem_name, 'asdoc/templates', gem_version)
        templates_dir = templates_dir.split('.exe').join('')
        templates_path << templates_dir
      end
    end

    def execute(*args)
      update_helper_mode
      begin
        super
      rescue ExecutionError => e
        if(e.message.index('Warning:'))
          # MXMLC sends warnings to stderr....
          Log.puts(e.message.gsub('[ERROR]', '[WARNING]'))
        else
          raise e
        end
      end
    end
    
    # The AsDoc package includes an asDocHelper binary that is packaged up without
    # the executable flag, calling Sprout::get_executable with this target will
    # automatically chmod it to 744.
    def update_helper_mode
      exe = Sprout.get_executable(gem_name, 'asdoc/templates/asDocHelper', gem_version)
    end

    def resolve_library(library_task)
      #TODO: Add support for libraries that don't get
      # copied into the project
      path = library_task.project_path
      if(path.match(/.swc$/))
        library_path << library_task.project_path
      else
        source_path << library_task.project_path
      end
    end

    # Requires that @exclude_expressions is not nil.
    def apply_exclusions_from_expression
      FileList[@exclude_expressions].each do |file_path|
        import_file = remove_source_path_from_file_path(file_path) || file_path
        import_class = filename_to_import_class(import_file)

        exclude_classes << import_class unless import_class.nil?
      end
    end

    def remove_source_path_from_file_path(file)
        source_path.each do |source_dir|
          import_file = file.sub(Regexp.new("^#{source_dir}"),"")
          return import_file if import_file != file
        end
        
        return file
    end

    def filename_to_import_class(filename)
      name = filename.scan(/\w+/)
      # Ignore the AS file extension.
      name[0..-2].join('.') unless name[-1] != 'as'
    end

  end
end

def asdoc(args, &block)
  return Sprout::AsDocTask.define_task(args, &block)
end

