module Sprout
class COMPCTask < ToolTask
# Enables accessibility features when compiling the Flex application or SWC file. The default value is false.
def accessible=(boolean)
  @accessible = boolean
end

# Sets the file encoding for ActionScript files. For more information see: http://livedocs.adobe.com/flex/2/docs/00001503.html#149244
def actionscript_file_encoding=(string)
  @actionscript_file_encoding = string
end

# Checks if a source-path entry is a subdirectory of another source-path entry. It helps make the package names of MXML components unambiguous. This is an advanced option.
def allow_source_path_overlap=(boolean)
  @allow_source_path_overlap = boolean
end

# Use the ActionScript 3.0 class-based object model for greater performance and better error reporting. In the class-based object model, most built-in functions are implemented as fixed methods of classes.
# 
# The default value is true. If you set this value to false, you must set the es option to true.
# 
# This is an advanced option.
def as3=(boolean)
  @as3 = boolean
end

# Prints detailed compile times to the standard output. The default value is true.
def benchmark=(boolean)
  @benchmark = boolean
end

# Sets the value of the {context.root} token in channel definitions in the flex-services.xml file. If you do not specify the value of this option, Flex uses an empty string.
#         
# For more information on using the {context.root} token, see http://livedocs.adobe.com/flex/2/docs/00001446.html#205687.
def context_root=(path)
  @context_root = path
end

# Sets metadata in the resulting SWF file. For more information, see Adding metadata to SWF files (http://livedocs.adobe.com/flex/2/docs/00001502.html#145380).
def contributor=(string)
  @contributor = string
end

# Sets metadata in the resulting SWF file. For more information, see Adding metadata to SWF files. (http://livedocs.adobe.com/flex/2/docs/00001502.html#145380)
def creator=(string)
  @creator = string
end

# Sets metadata in the resulting SWF file. For more information, see Adding metadata to SWF files. (http://livedocs.adobe.com/flex/2/docs/00001502.html#145380)
def date=(string)
  @date = string
end

# Generates a debug SWF file. This file includes line numbers and filenames of all the source files. When a run-time error occurs, the stacktrace shows these line numbers and filenames. This information is also used by the command-line debugger and the Flex Builder debugger. Enabling the debug option generates larger SWF files.
# 
# For the mxmlc compiler, the default value is false. For the compc compiler, the default value is true.
# 
# For SWC files generated with the compc compiler, set this value to true, unless the target SWC file is an RSL. In that case, set the debug option to false.
# 
# For information about the command-line debugger, see Using the Command-Line Debugger (http://livedocs.adobe.com/flex/2/docs/00001540.html#181846).
# 
# Flex also uses the verbose-stacktraces setting to determine whether line numbers are added to the stacktrace.
def debug=(boolean)
  @debug = boolean
end

# Lets you engage in remote debugging sessions with the Flash IDE. This is an advanced option.
def debug_password=(string)
  @debug_password = string
end

# Sets the application's background color. You use the 0x notation to set the color, as the following example shows:
# 
# -default-background-color=0xCCCCFF
# 
# The default value is null. The default background of a Flex application is an image of a gray gradient. You must override this image for the value of the default-background-color option to be visible. For more information, see Editing application settings (http://livedocs.adobe.com/flex/2/docs/00001504.html#138781).
# 
# This is an advanced option.
def default_background_color=(string)
  @default_background_color = string
end

# Sets the application's frame rate. The default value is 24. This is an advanced option.
def default_frame_rate=(number)
  @default_frame_rate = number
end

#         Defines the application's script execution limits.
# The max-recursion-depth value specifies the maximum depth of Adobe Flash Player call stack before Flash Player stops. This is essentially the stack overflow limit. The default value is 1000.
# 
# The max-execution-time value specifies the maximum duration, in seconds, that an ActionScript event handler can execute before Flash Player assumes that it is hung, and aborts it. The default value is 60 seconds. You cannot set this value above 60 seconds.
# 
# Example:
# 
# # 900 is new max-recursion-depth
# # 20 is new max-execution-time
# t.default_script_limits = '900 20'
# 
# You can override these settings in the application.
# 
# This is an advanced option.
def default_script_limits=(string)
  @default_script_limits = string
end

# Defines the default application size, in pixels for example: default_size = '950 550'. This is an advanced option.
def default_size=(string)
  @default_size = string
end

# Defines the location of the default style sheet. Setting this option overrides the implicit use of the defaults.css style sheet in the framework.swc file.
# 
# For more information on the defaults.css file, see Using Styles and Themes (http://livedocs.adobe.com/flex/2/docs/00000751.html#241755) in Flex 2 Developer's Guide.
# 
# This is an advanced option.
def default_css_url=(url)
  @default_css_url = url
end

# Define a global AS3 conditional compilation definition, e.g. -define=CONFIG::debugging,true or -define+=CONFIG::debugging,true (to append to existing definitions in flex-config.xml)  (advanced, repeatable)
def define=(string)
  @define = string
end

# Sets metadata in the resulting SWF file. For more information, see Adding metadata to SWF files (http://livedocs.adobe.com/flex/2/docs/00001502.html#145380).
def description=(string)
  @description = string
end

# Outputs the compiler options in the flex-config.xml file to the target path; for example:
# 
# mxmlc -dump-config myapp-config.xml
# 
# This is an advanced option.
def dump_config=(file)
  @dump_config = file
end

# Use the ECMAScript edition 3 prototype-based object model to allow dynamic overriding of prototype properties. In the prototype-based object model, built-in functions are implemented as dynamic properties of prototype objects.
# 
# You can set the strict option to true when you use this model, but it might result in compiler errors for references to dynamic properties.
# 
# The default value is false. If you set this option to true, you must set the es3 option to false.
# 
# This is an advanced option.
def es=(boolean)
  @es = boolean
end

# Sets a list of symbols to exclude from linking when compiling a SWF file.
# 
# This option provides compile-time link checking for external references that are dynamically linked.
# 
# For more information about dynamic linking, see About linking (http://livedocs.adobe.com/flex/2/docs/00001521.html#205852).
# 
# This is an advanced option.
def externs=(symbols)
  @externs = symbols
end

# Specifies a list of SWC files or directories to exclude from linking when compiling a SWF file. This option provides compile-time link checking for external components that are dynamically linked.
# 
# For more information about dynamic linking, see About linking (http://livedocs.adobe.com/flex/2/docs/00001521.html#205852).
# 
# You can use the += operator to append the new SWC file to the list of external libraries.
# 
# This parameter has been aliased as +el+.
def external_library_path=(files)
  @external_library_path = files
end

# Specifies source files to compile. This is the default option for the mxmlc compiler.
def file_specs=(files)
  @file_specs = files
end

# Specifies the range of Unicode settings for that language. For more information, see Using Styles and Themes (http://livedocs.adobe.com/flex/2/docs/00000751.html#241755) in Flex 2 Developer's Guide.
# 
# This is an advanced option.
def fonts_languages_language_range=(string)
  @fonts_languages_language_range = string
end

# Defines the font manager. The default is flash.fonts.JREFontManager. You can also use the flash.fonts.BatikFontManager. For more information, see Using Styles and Themes in Flex 2 Developer's Guide (http://livedocs.adobe.com/flex/2/docs/00000751.html#241755).
# 
# This is an advanced option.
def fonts_managers=(symbols)
  @fonts_managers = symbols
end

# Sets the maximum number of fonts to keep in the server cache. For more information, see Caching fonts and glyphs (http://livedocs.adobe.com/flex/2/docs/00001469.html#208457).
# 
# This is an advanced option.
def fonts_max_cached_fonts=(number)
  @fonts_max_cached_fonts = number
end

# Sets the maximum number of character glyph-outlines to keep in the server cache for each font face. For more information, see Caching fonts and glyphs (http://livedocs.adobe.com/flex/2/docs/00001469.html#208457).
# 
# This is an advanced option.
def fonts_max_glyphs_per_face=(number)
  @fonts_max_glyphs_per_face = number
end

# Specifies a SWF file frame label with a sequence of class names that are linked onto the frame.
# 
# For example: frames_frame = 'someLabel MyProject OtherProject FoodProject'
# 
# This is an advanced option.
def frames_frame=(string)
  @frames_frame = string
end

# Toggles the generation of an IFlexBootstrap-derived loader class.
# 
# This is an advanced option.
def generate_frame_loader=(boolean)
  @generate_frame_loader = boolean
end

# Enables the headless implementation of the Flex compiler. This sets the following:
# 
# System.setProperty('java.awt.headless', 'true')
# 
# The headless setting (java.awt.headless=true) is required to use fonts and SVG on UNIX systems without X Windows.
# 
# This is an advanced option.
def headless_server=(boolean)
  @headless_server = boolean
end

# Links all classes inside a SWC file to the resulting application SWF file, regardless of whether or not they are used.
# 
# Contrast this option with the library-path option that includes only those classes that are referenced at compile time.
# 
# To link one or more classes whether or not they are used and not an entire SWC file, use the includes option.
# 
# This option is commonly used to specify resource bundles.
def include_libraries=(files)
  @include_libraries = files
end

# Links one or more classes to the resulting application SWF file, whether or not those classes are required at compile time.
# 
# To link an entire SWC file rather than individual classes, use the include-libraries option.
def includes=(symbols)
  @includes = symbols
end

# Enables incremental compilation. For more information, see About incremental compilation (http://livedocs.adobe.com/flex/2/docs/00001506.html#153980).
# 
# This option is true by default for the Flex Builder application compiler. For the command-line compiler, the default is false. The web-tier compiler does not support incremental compilation.
def incremental=(boolean)
  @incremental = boolean
end

# Determines whether to keep the generated ActionScript class files.
# 
# The generated class files include stubs and classes that are generated by the compiler and used to build the SWF file.
# 
# The default location of the files is the /generated subdirectory, which is directly below the target MXML file. If the /generated directory does not exist, the compiler creates one.
# 
# The default names of the primary generated class files are filename-generated.as and filename-interface.as.
# 
# The default value is false.
# This is an advanced option.
def keep_generated_actionscript=(boolean)
  @keep_generated_actionscript = boolean
end

# Sets metadata in the resulting SWF file. For more information, see Adding metadata to SWF files (http://livedocs.adobe.com/flex/2/docs/00001502.html#145380).
def language=(string)
  @language = string
end

# Enables ABC bytecode lazy initialization.
# 
# The default value is false.
# 
# This is an advanced option.
def lazy_init=(boolean)
  @lazy_init = boolean
end

# <product> <serial-number>
# 
# Specifies a product and a serial number.  (repeatable)
#     
# This is an advanced option.
def license=(string)
  @license = string
end

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
def library_path=(files)
  @library_path = files
end

# Prints linking information to the specified output file. This file is an XML file that contains <def>, <pre>, and <ext> symbols showing linker dependencies in the final SWF file.
# 
# The file format output by this command can be used to write a file for input to the load-externs option.
# 
# For more information on the report, see Examining linker dependencies (http://livedocs.adobe.com/flex/2/docs/00001394.html#211202).
# 
# This is an advanced option.
def link_report=(file)
  @link_report = file
end

# Specifies the location of the configuration file that defines compiler options.
# 
# If you specify a configuration file, you can override individual options by setting them on the command line.
# 
# All relative paths in the configuration file are relative to the location of the configuration file itself.
# 
# Use the += operator to chain this configuration file to other configuration files.
# 
# For more information on using configuration files to provide options to the command-line compilers, see About configuration files (http://livedocs.adobe.com/flex/2/docs/00001490.html#138195).
def load_config=(file)
  @load_config = file
end

# Specifies the location of an XML file that contains <def>, <pre>, and <ext> symbols to omit from linking when compiling a SWF file. The XML file uses the same syntax as the one produced by the link-report option. For more information on the report, see Examining linker dependencies (http://livedocs.adobe.com/flex/2/docs/00001394.html#211202).
# 
# This option provides compile-time link checking for external components that are dynamically linked.
# 
# For more information about dynamic linking, see About linking (http://livedocs.adobe.com/flex/2/docs/00001521.html#205852).
# 
# This is an advanced option.
def load_externs=(file)
  @load_externs = file
end

# Specifies the locale that should be packaged in the SWF file (for example, en_EN). You run the mxmlc compiler multiple times to create SWF files for more than one locale, with only the locale option changing.
# 
# You must also include the parent directory of the individual locale directories, plus the token {locale}, in the source-path; for example:
# 
# mxmlc -locale en_EN -source-path locale/{locale} -file-specs MainApp.mxml
# 
# For more information, see Localizing Flex Applicationsin (http://livedocs.adobe.com/flex/2/docs/00000898.html#129288) Flex 2 Developer's Guide.
def locale=(string)
  @locale = string
end

# Sets metadata in the resulting SWF file. For more information, see Adding metadata to SWF files (http://livedocs.adobe.com/flex/2/docs/00001502.html#145380).
def localized_description=(string)
  @localized_description = string
end

# Sets metadata in the resulting SWF file. For more information, see Adding metadata to SWF files (http://livedocs.adobe.com/flex/2/docs/00001502.html#145380).
def localized_title=(string)
  @localized_title = string
end

# Specifies a namespace for the MXML file. You must include a URI and the location of the manifest file that defines the contents of this namespace. This path is relative to the MXML file.
# 
# For more information about manifest files, see About manifest files (http://livedocs.adobe.com/flex/2/docs/00001519.html#134676).
def namespaces_namespace=(string)
  @namespaces_namespace = string
end

# Enables the ActionScript optimizer. This optimizer reduces file size and increases performance by optimizing the SWF file's bytecode.
# 
# The default value is false.
def optimize=(boolean)
  @optimize = boolean
end

# Specifies the output path and filename for the resulting file. If you omit this option, the compiler saves the SWF file to the directory where the target file is located.
# 
# The default SWF filename matches the target filename, but with a SWF file extension.
# 
# If you use a relative path to define the filename, it is always relative to the current working directory, not the target MXML application root.
# 
# The compiler creates extra directories based on the specified filename if those directories are not present.
# 
# When using this option with the component compiler, the output is a SWC file rather than a SWF file.
def output=(file)
  @output = file
end

# Sets metadata in the resulting SWF file. For more information, see Adding metadata to SWF files (http://livedocs.adobe.com/flex/2/docs/00001502.html#145380).
def publisher=(string)
  @publisher = string
end

# XML text to store in the SWF metadata (overrides metadata.* configuration) (advanced)
def raw_metadata=(string)
  @raw_metadata = string
end

# Prints a list of resource bundles to input to the compc compiler to create a resource bundle SWC file. The filename argument is the name of the file that contains the list of bundles.
# 
# For more information, see Localizing Flex Applications (http://livedocs.adobe.com/flex/2/docs/00000898.html#129288) in Flex 2 Developer's Guide.
def resource_bundle_list=(file)
  @resource_bundle_list = file
end

# Specifies a list of run-time shared libraries (RSLs) to use for this application. RSLs are dynamically-linked at run time.
# 
# You specify the location of the SWF file relative to the deployment location of the application. For example, if you store a file named library.swf file in the web_root/libraries directory on the web server, and the application in the web root, you specify libraries/library.swf.
# 
# For more information about RSLs, see Using Runtime Shared Libraries. (http://livedocs.adobe.com/flex/2/docs/00001520.html#168690)
def runtime_shared_libraries=(urls)
  @runtime_shared_libraries = urls
end

# [path-element] [rsl-url] [policy-file-url] [rsl-url] [policy-file-url]
# alias -rslp
# (repeatable)
def runtime_shared_library_path=(string)
  @runtime_shared_library_path = string
end

# Specifies the location of the services-config.xml file. This file is used by Flex Data Services.
def services=(file)
  @services = file
end

# Shows warnings for ActionScript classes.
# 
# The default value is true.
# 
# For more information about viewing warnings and errors, see Viewing warnings and errors (http://livedocs.adobe.com/flex/2/docs/00001517.html#182413).
def show_actionscript_warnings=(boolean)
  @show_actionscript_warnings = boolean
end

# Shows a warning when Flash Player cannot detect changes to a bound property.
# 
# The default value is true.
# 
# For more information about compiler warnings, see Using SWC files (http://livedocs.adobe.com/flex/2/docs/00001505.html#158337).
def show_binding_warnings=(boolean)
  @show_binding_warnings = boolean
end

# Shows deprecation warnings for Flex components. To see warnings for ActionScript classes, use the show-actionscript-warnings option.
# 
# The default value is true.
# 
# For more information about viewing warnings and errors, see Viewing warnings and errors.
def show_deprecation_warnings=(boolean)
  @show_deprecation_warnings = boolean
end

# Adds directories or files to the source path. The Flex compiler searches directories in the source path for MXML or AS source files that are used in your Flex applications and includes those that are required at compile time.
# 
# You can use wildcards to include all files and subdirectories of a directory.
# 
# To link an entire library SWC file and not individual classes or directories, use the library-path option.
# 
# The source path is also used as the search path for the component compiler's include-classes and include-resource-bundles options.
# 
# You can also use the += operator to append the new argument to the list of existing source path entries.
def source_path=(paths)
  @source_path = paths
end

# Statically link the libraries specified by the -runtime-shared-libraries-path option.
# 
# alias -static-rsls
def static_link_runtime_shared_libraries=(boolean)
  @static_link_runtime_shared_libraries = boolean
end

# Prints undefined property and function calls; also performs compile-time type checking on assignments and options supplied to method calls.
# 
# The default value is true.
# 
# For more information about viewing warnings and errors, see Viewing warnings and errors (http://livedocs.adobe.com/flex/2/docs/00001517.html#182413).
def strict=(boolean)
  @strict = boolean
end

# Specifies the version of the player the application is targeting.
# 
# Features requiring a later version will not be compiled into the application. The minimum value supported is "9.0.0".
def target_player=(string)
  @target_player = string
end

# Specifies a list of theme files to use with this application. Theme files can be SWC files with CSS files inside them or CSS files.
# 
# For information on compiling a SWC theme file, see Using Styles and Themes (http://livedocs.adobe.com/flex/2/docs/00000751.html#241755) in Flex 2 Developer's Guide.
def theme=(files)
  @theme = files
end

# Sets metadata in the resulting SWF file. For more information, see Adding metadata to SWF files (http://livedocs.adobe.com/flex/2/docs/00001502.html#145380).
def title=(string)
  @title = string
end

# Specifies that the current application uses network services.
# 
# The default value is true.
# 
# When the use-network property is set to false, the application can access the local filesystem (for example, use the XML.load() method with file: URLs) but not network services. In most circumstances, the value of this property should be true.
# 
# For more information about the use-network property, see Applying Flex Security (http://livedocs.adobe.com/flex/2/docs/00001328.html#137544).
def use_network=(boolean)
  @use_network = boolean
end

# Generates source code that includes line numbers. When a run-time error occurs, the stacktrace shows these line numbers.
# 
# Enabling this option generates larger SWF files.
# The default value is false.
def verbose_stacktraces=(boolean)
  @verbose_stacktraces = boolean
end

# Verifies the libraries loaded at runtime are the correct ones.
def verify_digests=(boolean)
  @verify_digests = boolean
end

# Enables specified warnings. For more information, see Viewing warnings and errors (http://livedocs.adobe.com/flex/2/docs/00001517.html#182413).
def warn_warning_type=(boolean)
  @warn_warning_type = boolean
end

# Enables all warnings. Set to false to disable all warnings. This option overrides the warn-warning_type options.
# 
# The default value is true.
def warnings=(boolean)
  @warnings = boolean
end

# Main source file to send compiler
def input=(file)
  @input = file
end

# Outputs the SWC file in an open directory format rather than a SWC file. You use this option with the output option to specify a destination directory, as the following example shows:
# compc -directory -output destination_directory
# 
# You use this option when you create RSLs. For more information, see Using Runtime Shared Libraries (http://livedocs.adobe.com/flex/201/html/rsl_124_1.html#168690).
def directory=(boolean)
  @directory = boolean
end

# Specifies classes to include in the SWC file. You provide the class name (for example, MyClass) rather than the file name (for example, MyClass.as) to the file for this option. As a result, all classes specified with this option must be in the compiler's source path. You specify this by using the source-path compiler option.
# 
# You can use packaged and unpackaged classes. To use components in namespaces, use the include-namespaces option.
# 
# If the components are in packages, ensure that you use dot-notation rather than slashes to separate package levels.
# 
# This is the default option for the component compiler.
def include_classes=(symbols)
  @include_classes = symbols
end

# Adds the file to the SWC file. This option does not embed files inside the library.swf file. This is useful for skinning and theming, where you want to add non-compiled files that can be referenced in a style sheet or embedded as assets in MXML files.
# 
# If you use the [Embed] syntax to add a resource to your application, you are not required to use this option to also link it into the SWC file.
# 
# For more information, see Adding nonsource classes (http://livedocs.adobe.com/flex/201/html/compilers_123_39.html#158900).
def include_file=(files)
  @include_file = files
end

# 
def include_lookup_only=(boolean)
  @include_lookup_only = boolean
end

# Specifies namespace-style components in the SWC file. You specify a list of URIs to include in the SWC file. The uri argument must already be defined with the namespace option.
# 
# To use components in packages, use the include-classes option.
def include_namespaces=(urls)
  @include_namespaces = urls
end

# Specifies the resource bundles to include in this SWC file. All resource bundles specified with this option must be in the compiler's source path. You specify this using the source-path compiler option.
# 
# For more information on using resource bundles, see Localizing Flex Applications (http://livedocs.adobe.com/flex/201/html/l10n_076_1.html#129288) in Flex 2 Developer's Guide.
def include_resource_bundles=(files)
  @include_resource_bundles = files
end

# Specifies classes or directories to add to the SWC file. When specifying classes, you specify the path to the class file (for example, MyClass.as) rather than the class name itself (for example, MyClass). This lets you add classes to the SWC file that are not in the source path. In general, though, use the include-classes option, which lets you add classes that are in the source path.
# 
# If you specify a directory, this option includes all files with an MXML or AS extension, and ignores all other files.
def include_sources=(paths)
  @include_sources = paths
end

# Not sure about this option, it was in the CLI help, but not documented on the Adobe site
def namespace=(string)
  @namespace = string
end

end
end
