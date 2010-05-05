
module Sprout

  class MXMLCError < Sprout::Errors::SproutError #:nodoc:
  end
  
  class ExecutionError < Sprout::Errors::SproutError #:nodoc:
  end
  
  # The MXMLC task provides a rake front end to the Flex MXMLC command line compiler.
  # This task is integrated with the LibraryTask so that if any dependencies are
  # library tasks, they will be automatically added to the library_path or source_path
  # depending on whether they provide a swc or sources.
  #
  # The entire MXMLC advanced interface has been provided here. All parameter names should be
  # identical to what is available on the regular compiler except dashes have been replaced
  # by underscores.
  #
  # The following example can be pasted in a file named 'rakefile.rb' which should be placed in
  # the same folder as an ActionScript 3.0 class named 'SomeProject.as' that extends
  # flash.display.Sprite.
  #
  #   # Create a remote library dependency on the corelib swc.
  #   library :corelib
  # 
  #   # Alias the compilation task with one that is easier to type
  #   task :compile => 'SomeProject.swf'
  #
  #   # Create an MXMLCTask named for the output file that it creates. This task depends on the
  #   # corelib library and will automatically add the corelib.swc to it's library_path
  #   mxmlc 'SomeProject.swf' => :corelib do |t|
  #     t.input                     = 'SomeProject.as'
  #     t.default_size              = '800 600'
  #     t.default_background_color  = "#FFFFFF"
  #   end
  #
  # Note: Be sure to check out the features of the ToolTask to learn more about gem_version and preprocessor
  #
  class MXMLCTask
    include Sprout::Tool
    
    ##
    # Enables accessibility features when compiling the Flex application or SWC file. The default value is false.
    #
    add_param :accessible, { :type => :boolean, :hidden_value => true }
    
    ##
    # Sets the file encoding for ActionScript files. For more information see: http://livedocs.adobe.com/flex/2/docs/00001503.html#149244
    #
    add_param :actionscript_file_encoding, :string
    
    ##
    # Checks if a source-path entry is a subdirectory of another source-path entry. It helps make the package names of MXML components unambiguous. This is an advanced option.
    #
    add_param :allow_source_path_overlap, { :type => :boolean, :hidden_value => true }

    ##
    # Use the ActionScript 3.0 class-based object model for greater performance and better error reporting. In the class-based object model, most built-in functions are implemented as fixed methods of classes.
    #
    # The default value is true. If you set this value to false, you must set the es option to true.
    #
    # This is an advanced option.
    add_param :as3, { :type => :boolean, :value => true, :show_on_false => true }
    
    ##
    # Prints detailed compile times to the standard output. The default value is true.
    #
    add_param :benchmark, { :type => :boolean, :value => true, :show_on_false => true }
    
    ##
    # Sets the value of the {context.root} token in channel definitions in the flex-services.xml file. If you do not specify the value of this option, Flex uses an empty string.
    #
    # For more information on using the {context.root} token, see http://livedocs.adobe.com/flex/2/docs/00001446.html#205687.
    #
    add_param :context_root, :path
    
    ##
    # Sets metadata in the resulting SWF file. For more information, see Adding metadata to SWF files (http://livedocs.adobe.com/flex/2/docs/00001502.html#145380).
    #
    add_param :contributor, :string
    
    ##
    # Sets metadata in the resulting SWF file. For more information, see Adding metadata to SWF files. (http://livedocs.adobe.com/flex/2/docs/00001502.html#145380)
    #
    add_param :creator, :string
    
    ##
    # Sets metadata in the resulting SWF file. For more information, see Adding metadata to SWF files. (http://livedocs.adobe.com/flex/2/docs/00001502.html#145380)
    #
    add_param :date, :string
    
    ##
    # Generates a debug SWF file. This file includes line numbers and filenames of all the source files. When a run-time error occurs, the stacktrace shows these line numbers and filenames. This information is also used by the command-line debugger and the Flex Builder debugger. Enabling the debug option generates larger SWF files.
    #
    # For the mxmlc compiler, the default value is false. For the compc compiler, the default value is true. 
    # 
    # For SWC files generated with the compc compiler, set this value to true, unless the target SWC file is an RSL. In that case, set the debug option to false.
    #
    # For information about the command-line debugger, see Using the Command-Line Debugger (http://livedocs.adobe.com/flex/2/docs/00001540.html#181846).
    #
    # Flex also uses the verbose-stacktraces setting to determine whether line numbers are added to the stacktrace.
    #
    add_param :debug, { :type => :boolean, :hidden_value => true }
    
    ##
    # Lets you engage in remote debugging sessions with the Flash IDE. This is an advanced option.
    #
    add_param :debug_password, :string
    
    ##
    # Sets the application's background color. You use the 0x notation to set the color, as the following example shows:
    # 
    #     -default-background-color=0xCCCCFF
    #
    # The default value is null. The default background of a Flex application is an image of a gray gradient. You must override this image for the value of the default-background-color option to be visible. For more information, see Editing application settings (http://livedocs.adobe.com/flex/2/docs/00001504.html#138781).
    #
    # This is an advanced option.
    # 
    add_param :default_background_color, :string
    
    ##
    # Sets the application's frame rate. The default value is 24. This is an advanced option.
    #
    add_param :default_frame_rate, :number
    
    ##
    # Defines the application's script execution limits.
    #
    # The max-recursion-depth value specifies the maximum depth of Adobe Flash Player call stack before Flash Player stops. This is essentially the stack overflow limit. The default value is 1000.
    #
    # The max-execution-time value specifies the maximum duration, in seconds, that an ActionScript event handler can execute before Flash Player assumes that it is hung, and aborts it. The default value is 60 seconds. You cannot set this value above 60 seconds.
    #
    # Example:
    #
    #     # 900 is new max-recursion-depth
    #     # 20 is new max-execution-time
    #     t.default_script_limits = '900 20'
    #
    # You can override these settings in the application.
    #
    # This is an advanced option.
    #
    add_param :default_script_limits, :string
    
    ##
    # Defines the default application size, in pixels for example: default_size = '950 550'. This is an advanced option.
    #
    add_param :default_size, { :type => :string, :delimiter => ' ' }
    
    ##
    # Defines the location of the default style sheet. Setting this option overrides the implicit use of the defaults.css style sheet in the framework.swc file.
    #
    # For more information on the defaults.css file, see Using Styles and Themes (http://livedocs.adobe.com/flex/2/docs/00000751.html#241755) in Flex 2 Developer's Guide.
    #
    # This is an advanced option.
    #
    add_param :default_css_url, :url

    ##
    # This parameter is normally called 'define' but thanks to scoping issues with Sprouts and Rake, we needed to rename it and chose: 'define_conditional'.
    #
    # Define a global AS3 conditional compilation definition, e.g. -define=CONFIG::debugging,true or -define+=CONFIG::debugging,true (to append to existing definitions in flex-config.xml)  (advanced, repeatable)
    #
    add_param :define_conditional, { :type => :strings, :shell_name => "-define" }
    
    ##
    # Sets metadata in the resulting SWF file. For more information, see Adding metadata to SWF files (http://livedocs.adobe.com/flex/2/docs/00001502.html#145380).
    #
    add_param :description, :string
    
    ##
    # Outputs the compiler options in the flex-config.xml file to the target path; for example:
    #
    #     mxmlc -dump-config myapp-config.xml
    #
    # This is an advanced option.
    #
    add_param :dump_config, :file
    
    ##
    # Use the ECMAScript edition 3 prototype-based object model to allow dynamic overriding of prototype properties. In the prototype-based object model, built-in functions are implemented as dynamic properties of prototype objects.
    #
    # You can set the strict option to true when you use this model, but it might result in compiler errors for references to dynamic properties.
    #
    # The default value is false. If you set this option to true, you must set the es3 option to false.
    #
    # This is an advanced option.
    #
    add_param :es, :boolean
    
    ##
    # Sets a list of symbols to exclude from linking when compiling a SWF file.
    #
    # This option provides compile-time link checking for external references that are dynamically linked.
    #
    # For more information about dynamic linking, see About linking (http://livedocs.adobe.com/flex/2/docs/00001521.html#205852).
    #
    # This is an advanced option.
    # 
    add_param :externs, :symbols
    
    ##
    # Specifies a list of SWC files or directories to exclude from linking when compiling a SWF file. This option provides compile-time link checking for external components that are dynamically linked.
    #
    # For more information about dynamic linking, see About linking (http://livedocs.adobe.com/flex/2/docs/00001521.html#205852).
    #
    # You can use the += operator to append the new SWC file to the list of external libraries.
    #
    # This parameter has been aliased as +el+.
    #
    add_param :external_library_path, :files
    
    ##
    # Alias for external_library_path
    #
    add_param_alias :el, :external_library_path
    
    ##
    # Specifies source files to compile. This is the default option for the mxmlc compiler.
    #
    add_param :file_specs, :files
    
    ##
    # Specifies the range of Unicode settings for that language. For more information, see Using Styles and Themes (http://livedocs.adobe.com/flex/2/docs/00000751.html#241755) in Flex 2 Developer's Guide.
    #
    # This is an advanced option.
    #
    add_param :fonts_languages_language_range, { :type => :string, :shell_name => "-compiler.fonts.languages.language-range" }

    ##
    # Defines the font manager. The default is flash.fonts.JREFontManager. You can also use the flash.fonts.BatikFontManager. For more information, see Using Styles and Themes in Flex 2 Developer's Guide (http://livedocs.adobe.com/flex/2/docs/00000751.html#241755).
    #
    # This is an advanced option.
    #
    add_param :fonts_managers, :symbols
    
    ##
    # Sets the maximum number of fonts to keep in the server cache. For more information, see Caching fonts and glyphs (http://livedocs.adobe.com/flex/2/docs/00001469.html#208457).
    #
    # This is an advanced option.
    #
    add_param :fonts_max_cached_fonts, :number
    
    ##
    # Sets the maximum number of character glyph-outlines to keep in the server cache for each font face. For more information, see Caching fonts and glyphs (http://livedocs.adobe.com/flex/2/docs/00001469.html#208457).
    #
    # This is an advanced option.
    # 
    add_param :fonts_max_glyphs_per_face, :number
    
    ##
    # Specifies a SWF file frame label with a sequence of class names that are linked onto the frame.
    #
    # For example: frames_frame = 'someLabel MyProject OtherProject FoodProject'
    #
    # This is an advanced option.
    # 
    add_param :frames_frame, { :type => :string, :shell_name => '-frames.frame' }
    
    ##
    # Toggles the generation of an IFlexBootstrap-derived loader class.
    #
    # This is an advanced option.
    #
    add_param :generate_frame_loader, :boolean
    
    ##
    # Enables the headless implementation of the Flex compiler. This sets the following:
    #
    #     System.setProperty('java.awt.headless', 'true')
    #
    # The headless setting (java.awt.headless=true) is required to use fonts and SVG on UNIX systems without X Windows.
    #
    # This is an advanced option.
    #
    add_param :headless_server, :boolean
    
    ##
    # Links all classes inside a SWC file to the resulting application SWF file, regardless of whether or not they are used.
    #
    # Contrast this option with the library-path option that includes only those classes that are referenced at compile time.
    #
    # To link one or more classes whether or not they are used and not an entire SWC file, use the includes option.
    #
    # This option is commonly used to specify resource bundles.
    #
    add_param :include_libraries, :files

    ##
    # Links one or more classes to the resulting application SWF file, whether or not those classes are required at compile time.
    #
    # To link an entire SWC file rather than individual classes, use the include-libraries option.
    #
    add_param :includes, :symbols
    
    ##
    # Define one or more directory paths for include processing. For each path that is provided, all .as and .mxml files found forward of that path will
    # be included in the SWF regardless of whether they are imported or not.
    add_param :include_path, :paths
    
    ##
    # Enables incremental compilation. For more information, see About incremental compilation (http://livedocs.adobe.com/flex/2/docs/00001506.html#153980).
    # 
    # This option is true by default for the Flex Builder application compiler. For the command-line compiler, the default is false. The web-tier compiler does not support incremental compilation.
    #
    add_param :incremental, :boolean
    
    ##
    # Keep the specified metadata in the SWF (advanced, repeatable).
    #
    # Example:
    #
    # Rakefile:
    #
    #     mxmlc 'bin/SomeProject.swf' do |t|
    #       t.keep_as3_metadata << 'Orange'
    #     end
    #
    # Source Code:
    #
    #     [Orange(isTasty=true)]
    #     public function eatOranges():void {
    #         // do something
    #     }
    #
    add_param :keep_as3_metadata, :symbols
    
    ##
    # Determines whether to keep the generated ActionScript class files.
    #
    # The generated class files include stubs and classes that are generated by the compiler and used to build the SWF file.
    #
    # The default location of the files is the /generated subdirectory, which is directly below the target MXML file. If the /generated directory does not exist, the compiler creates one.
    #
    # The default names of the primary generated class files are filename-generated.as and filename-interface.as.
    #
    # The default value is false.\nThis is an advanced option.
    #
    add_param :keep_generated_actionscript, :boolean
    
    ##
    # Sets metadata in the resulting SWF file. For more information, see Adding metadata to SWF files (http://livedocs.adobe.com/flex/2/docs/00001502.html#145380).
    #
    add_param :language, :string
    
    ##
    # Enables ABC bytecode lazy initialization.
    #
    # The default value is false.
    #
    # This is an advanced option.
    #
    add_param :lazy_init, :boolean


    ##
    # <product> <serial-number>
    #
    # Specifies a product and a serial number.  (repeatable)
    #
    # This is an advanced option.
    #
    add_param :license, :string
    
    ##
    # Links SWC files to the resulting application SWF file. The compiler only links in those classes for the SWC file that are required.
    #
    # The default value of the library-path option includes all SWC files in the libs directory and the current locale. These are required.
    #
    # To point to individual classes or packages rather than entire SWC files, use the source-path option.
    #
    # If you set the value of the library-path as an option of the command-line compiler, you must also explicitly add the framework.swc and locale SWC files. Your new entry is not appended to the library-path but replaces it.
    #
    # You can use the += operator to append the new argument to the list of existing SWC files.
    #
    # In a configuration file, you can set the append attribute of the library-path tag to true to indicate that the values should be appended to the library path rather than replace it.
    #
    add_param :library_path, :files
    
    ##
    # Alias to library_path
    #
    add_param_alias :l, :library_path
    
    ##
    # Prints linking information to the specified output file. 
    # This file is an XML file that contains 
    #
    #     <def>, <pre>, and <ext> 
    #
    # symbols showing linker dependencies in the final SWF file.
    #
    # The file format output by this command can be used to write a file for input to the load-externs option.
    #
    # For more information on the report, see Examining linker dependencies (http://livedocs.adobe.com/flex/2/docs/00001394.html#211202).
    #
    # This is an advanced option.
    #
    add_param :link_report, :file
    
    ##
    # Specifies the location of the configuration file that defines compiler options.
    #
    # If you specify a configuration file, you can override individual options by setting them on the command line.
    #
    # All relative paths in the configuration file are relative to the location of the configuration file itself.
    #
    # Use the += operator to chain this configuration file to other configuration files.
    #
    # For more information on using configuration files to provide options to the command-line compilers, see About configuration files (http://livedocs.adobe.com/flex/2/docs/00001490.html#138195).
    #
    add_param :load_config, :files
    
    ##
    # Specifies the location of an XML file that contains 
    #
    #     <def>, <pre>, and <ext> 
    #
    # symbols to omit from linking when compiling a SWF file. 
    #
    # The XML file uses the same syntax as the one produced by the link-report option. 
    #
    # For more information on the report, see Examining linker dependencies (http://livedocs.adobe.com/flex/2/docs/00001394.html#211202).
    #
    # This option provides compile-time link checking for external components that are dynamically linked.
    #
    # For more information about dynamic linking, see About linking (http://livedocs.adobe.com/flex/2/docs/00001521.html#205852).
    #
    # This is an advanced option.
    #
    add_param :load_externs, :file
    
    ##
    # Specifies the locale that should be packaged in the SWF file (for example, en_EN). 
    #
    # You run the mxmlc compiler multiple times to create SWF files for more than one locale, 
    # with only the locale option changing.
    #
    # You must also include the parent directory of the individual locale directories, 
    # plus the token {locale}, in the source-path; for example:
    #
    #      mxmlc -locale en_EN -source-path locale/{locale} -file-specs MainApp.mxml
    #
    # For more information, see Localizing Flex Applicationsin (http://livedocs.adobe.com/flex/2/docs/00000898.html#129288) Flex 2 Developer's Guide.
    #
    add_param :locale, :string
    
    ##
    # Sets metadata in the resulting SWF file. For more information, see Adding metadata to SWF files (http://livedocs.adobe.com/flex/2/docs/00001502.html#145380).
    #
    add_param :localized_description, :string

    ##
    # Sets metadata in the resulting SWF file. For more information, see Adding metadata to SWF files (http://livedocs.adobe.com/flex/2/docs/00001502.html#145380)."
    #
    add_param :localized_title, :string
    
    ##
    # Specifies a namespace for the MXML file. You must include a URI and the location of the manifest file that defines the contents of this namespace. This path is relative to the MXML file.
    #
    # For more information about manifest files, see About manifest files (http://livedocs.adobe.com/flex/2/docs/00001519.html#134676).
    #
    add_param :namespaces_namespace, :string
    
    ##
    # Enables the ActionScript optimizer. This optimizer reduces file size and increases performance by optimizing the SWF file's bytecode.
    #
    # The default value is false.
    #
    add_param :optimize, :boolean
    
    ##
    # Specifies the output path and filename for the resulting file. If you omit this option, the compiler saves the SWF file to the directory where the target file is located.
    #
    # The default SWF filename matches the target filename, but with a SWF file extension.
    #
    # If you use a relative path to define the filename, it is always relative to the current working directory, not the target MXML application root.
    #
    # The compiler creates extra directories based on the specified filename if those directories are not present.
    #
    # When using this option with the component compiler, the output is a SWC file rather than a SWF file.
    #
    add_param :output, :file
    
    ##
    # Sets metadata in the resulting SWF file. For more information, see Adding metadata to SWF files (http://livedocs.adobe.com/flex/2/docs/00001502.html#145380).
    #
    add_param :publisher, :string

    ##
    # XML text to store in the SWF metadata (overrides metadata.* configuration) (advanced)
    #
    add_param :raw_metadata, :string
    
    ##
    # Prints a list of resource bundles to input to the compc compiler to create a resource bundle SWC file. The filename argument is the name of the file that contains the list of bundles.
    #
    # For more information, see Localizing Flex Applications (http://livedocs.adobe.com/flex/2/docs/00000898.html#129288) in Flex 2 Developer's Guide.
    #
    add_param :resource_bundle_list, :file
    
    ##
    # Specifies a list of run-time shared libraries (RSLs) to use for this application. RSLs are dynamically-linked at run time.
    #
    # You specify the location of the SWF file relative to the deployment location of the application. For example, if you store a file named library.swf file in the web_root/libraries directory on the web server, and the application in the web root, you specify libraries/library.swf.
    #
    # For more information about RSLs, see Using Runtime Shared Libraries. (http://livedocs.adobe.com/flex/2/docs/00001520.html#168690)
    #
    add_param :runtime_shared_libraries, :urls

    ## 
    # Alias for runtime_shared_libraries
    #
    add_param_alias :rsl, :runtime_shared_libraries

    ##
    # [path-element] [rsl-url] [policy-file-url] [rsl-url] [policy-file-url]
    # alias -rslp
    # (repeatable)
    add_param :runtime_shared_library_path, :string
    
    ##
    # Alias for runtime_shared_library_path
    #
    add_param_alias :rslp, :runtime_shared_library_path
    
    ##
    # Specifies the location of the services-config.xml file. This file is used by Flex Data Services.
    #
    add_param :services, :file

    ##
    # Shows warnings for ActionScript classes.
    #
    # The default value is true.
    #
    # For more information about viewing warnings and errors, see Viewing warnings and errors (http://livedocs.adobe.com/flex/2/docs/00001517.html#182413).
    #
    add_param :show_actionscript_warnings, { :type => :boolean, :value => true, :show_on_false => true }

    ##
    # Shows a warning when Flash Player cannot detect changes to a bound property.
    #
    # The default value is true.
    #
    # For more information about compiler warnings, see Using SWC files (http://livedocs.adobe.com/flex/2/docs/00001505.html#158337).
    #
    add_param :show_binding_warnings, { :type => :boolean, :value => true, :show_on_false => true }
    
    ##
    # Shows deprecation warnings for Flex components. To see warnings for ActionScript classes, use the show-actionscript-warnings option.
    #
    # The default value is true.
    #
    # For more information about viewing warnings and errors, see Viewing warnings and errors.
    #
    add_param :show_deprecation_warnings, { :type => :boolean, :value => true, :show_on_false => true }
    
    ##
    # Adds directories or files to the source path. The Flex compiler searches directories in the source path for MXML or AS source files that are used in your Flex applications and includes those that are required at compile time.
    #
    # You can use wildcards to include all files and subdirectories of a directory.
    #
    # To link an entire library SWC file and not individual classes or directories, use the library-path option.
    #
    # The source path is also used as the search path for the component compiler's include-classes and include-resource-bundles options.
    #
    # You can also use the += operator to append the new argument to the list of existing source path entries.
    #
    add_param :source_path, { :type => :paths, :preprocessable => true }
    
    add_param_alias :sp, :source_path 

    ##
    # Statically link the libraries specified by the -runtime-shared-libraries-path option.
    #
    #     alias -static-rsls
    #
    add_param :static_link_runtime_shared_libraries, :boolean

    ##
    # Alias for static_link_runtime_shared_libraries
    #
    add_param_alias :static_rsls, :static_link_runtime_shared_libraries 
    
    ##
    # Prints undefined property and function calls; also performs compile-time type checking on assignments and options supplied to method calls.
    #
    # The default value is true.
    #
    # For more information about viewing warnings and errors, see Viewing warnings and errors (http://livedocs.adobe.com/flex/2/docs/00001517.html#182413).
    #
    add_param :strict, { :type => :boolean, :value => true, :show_on_false => true }
    
    ##
    # Specifies the version of the player the application is targeting.
    #
    # Features requiring a later version will not be compiled into the application. The minimum value supported is "9.0.0".
    #
    add_param :target_player, :string
    
    ##
    # Specifies a list of theme files to use with this application. Theme files can be SWC files with CSS files inside them or CSS files.
    #
    # For information on compiling a SWC theme file, see Using Styles and Themes (http://livedocs.adobe.com/flex/2/docs/00000751.html#241755) in Flex 2 Developer's Guide.
    #
    add_param :theme, :files
    
    ##
    # Sets metadata in the resulting SWF file. For more information, see Adding metadata to SWF files (http://livedocs.adobe.com/flex/2/docs/00001502.html#145380).
    #
    add_param :title, :string
    
    ##
    # Specifies that the current application uses network services.
    #
    # The default value is true.
    #
    # When the use-network property is set to false, the application can access the local filesystem (for example, use the XML.load() method with file: URLs) but not network services. In most circumstances, the value of this property should be true.
    #
    # For more information about the use-network property, see Applying Flex Security (http://livedocs.adobe.com/flex/2/docs/00001328.html#137544).
    #
    add_param :use_network, { :type => :boolean, :value => true, :show_on_false => true }
    
    ##
    # Generates source code that includes line numbers. When a run-time error occurs, the stacktrace shows these line numbers.
    #
    # Enabling this option generates larger SWF files.\nThe default value is false.
    #
    add_param :verbose_stacktraces, :boolean

    ##
    # Verifies the libraries loaded at runtime are the correct ones.
    #
    add_param :verify_digests, :boolean
  
    ##
    # Enables specified warnings. For more information, see Viewing warnings and errors (http://livedocs.adobe.com/flex/2/docs/00001517.html#182413).
    #
    add_param :warn_warning_type, :boolean
    
    ##
    # Enables all warnings. Set to false to disable all warnings. This option overrides the warn-warning_type options.
    #
    # The default value is true.
    #
    add_param :warnings, :boolean

    ##
    # Main source file to send compiler"
    # This must be the last item in this list
    add_param :input, { :type => :file, :required => true, :preprocessable => true, :hidden_name => true }

    # Use a running instance of the FCSH command shell to speed up compilation.
    # You need to run 'rake fcsh:start' in another terminal before turning on 
    # this flag and compiling.
    def use_fcsh=(use)
      @use_fcsh = use
    end

    def use_fcsh
      @use_fcsh
    end

    # Interface and descriptions found here:
    # http://livedocs.adobe.com/flex/2/docs/wwhelp/wwhimpl/common/html/wwhelp.htm?context=LiveDocs_Parts&file=00001481.html
    def initialize
      super
      @default_gem_name = 'sprout-flex3sdk-tool'
      @default_gem_path = 'bin/mxmlc'
    end
    
  end
end

=begin
    def define # :nodoc:
      super

      if(!output)
        if(name.match(/.swf/) || name.match(/swc/))
          self.output = name
        end
      end
      
      if(input && !input.match(/.css/) && File.exists?(input))
        source_path << File.dirname(input)
      end
      
      if(include_path)
        include_path.each do |path|
          process_include_path(path) if(File.directory?(path))
        end
      end
      
      self.include_path = []
      
      if(link_report)
        CLEAN.add(link_report)
      end
      
      source_path.uniq!
      param_hash['source_path'].value = clean_nested_source_paths(source_path)
      
      CLEAN.add(output)
      if(incremental)
        CLEAN.add(FileList['**/**/*.cache'])
      end

      self
    end
    
    protected 
    
    def process_include_path(path)
      symbols = []
      FileList["#{path}/**/*[.as|.mxml]"].each do |file|
        next if File.directory?(file)
        file.gsub!(path, '')
        file.gsub!(/^\//, '')
        file.gsub!('/', '.')
        file.gsub!(/.as$/, '')
        file.gsub!(/.mxml$/, '')
        file.gsub!(/.css$/, '')
        symbols << file
      end
      
      symbols.each do |symbol|
        self.includes << symbol
      end
    end
    
    def clean_nested_source_paths(paths)
      results = []
      paths.each do |path|
        # TODO: This should only happen if: allow_source_path_overlap != true
        if(check_nested_source_path(results, path))
          results << path
        end
      end
      return results
    end
    
    def check_nested_source_path(array, path)
      array.each_index do |index|
        item = array[index]
        if(item =~ /^#{path}/)
          array.slice!(index, 1)
        elsif(path =~ /^#{item}/)
          return false
        end
      end
      return true
    end

    # Use the swc path if possible
    # Otherwise add to source
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
    
    def execute_with_fcsh(command)
      begin
        display_preprocess_message
        puts FCSHSocket.execute("mxmlc #{command}")
      rescue FCSHError => fcsh_error
        raise fcsh_error
      rescue StandardError => std_error
        # TODO: Capture a more concrete error here...
        raise MXMLCError.new("[ERROR] There was a problem connecting to the Flex Compiler SHell, run 'rake fcsh:start' in another terminal.")
      end
    end
    
    def execute(*args)
      begin
        start = Time.now.to_i
        if(@use_fcsh)
          execute_with_fcsh(to_shell)
        else
          super
        end
        Log.puts "mxmlc finished compiling #{name} in #{Time.now.to_i - start} seconds"
      rescue ExecutionError => e
        if(e.message.index('Warning:'))
          # MXMLC sends warnings to stderr....
          Log.puts(e.message.gsub('[ERROR]', '[WARNING]'))
        else
          raise e
        end
      end
    end

  end
end

# Helper method for definining and accessing MXMLCTask instances in a rakefile
def mxmlc(args, &block)
  Sprout::MXMLCTask.define_task(args, &block)
end

=end

def mxmlc args
  mxmlc_tool = Sprout::MXMLCTask.new
  yield mxmlc_tool if block_given?
  file args do
    mxmlc_tool.execute
  end
  mxmlc_tool
end

