module Sprout
class AsDocTask < ToolTask
# Sets the file encoding for ActionScript files. For more information see: http://livedocs.adobe.com/flex/2/docs/00001503.html#149244
def actionscript_file_encoding=(string)
  @actionscript_file_encoding = string
end

# Prints detailed compile times to the standard output. The default value is true.
def benchmark=(boolean)
  @benchmark = boolean
end

# A list of classes to document. These classes must be in the source path. This is the default option.
# 
# This option works the same way as does the -include-classes option for the compc component compiler. For more information, see Using the component compiler (http://livedocs.adobe.com/flex/201/html/compilers_123_31.html#162910).
def doc_classes=(strings)
  @doc_classes = strings
end

# A list of URIs whose classes should be documented. The classes must be in the source path.
# 
# You must include a URI and the location of the manifest file that defines the contents of this namespace.
# 
# This option works the same way as does the -include-namespaces option for the compc component compiler. For more information, see Using the component compiler. (http://livedocs.adobe.com/flex/201/html/compilers_123_31.html#162910)
def doc_namespaces=(strings)
  @doc_namespaces = strings
end

# A list of files that should be documented. If a directory name is in the list, it is recursively searched.
# 
# This option works the same way as does the -include-sources option for the compc component compiler. For more information, see Using the component compiler (http://livedocs.adobe.com/flex/201/html/compilers_123_31.html#162910).
def doc_sources=(paths)
  @doc_sources = paths
end

# A list of classes that should not be documented. You must specify individual class names. Alternatively, if the ASDoc comment for the class contains the @private tag, is not documented.
def exclude_classes=(strings)
  @exclude_classes = strings
end

# Whether all dependencies found by the compiler are documented. If true, the dependencies of the input classes are not documented.
# 
# The default value is false.
def exclude_dependencies=(boolean)
  @exclude_dependencies = boolean
end

# The text that appears at the bottom of the HTML pages in the output documentation.
def footer=(string)
  @footer = string
end

# An integer that changes the width of the left frameset of the documentation. You can change this size to accommodate the length of your package names.
# 
# The default value is 210 pixels.
def left_frameset_width=(number)
  @left_frameset_width = number
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

# The text that appears at the top of the HTML pages in the output documentation.
# 
# The default value is "API Documentation".
def main_title=(string)
  @main_title = string
end

# Not sure about this option, it was in the CLI help, but not documented on the Adobe site
def namespace=(string)
  @namespace = string
end

# The output directory for the generated documentation. The default value is "doc".
def output=(path)
  @output = path
end

# The descriptions to use when describing a package in the documentation. You can specify more than one package option.
# 
# The following example adds two package descriptions to the output:
# asdoc -doc-sources my_dir -output myDoc -package com.my.business "Contains business classes and interfaces" -package com.my.commands "Contains command base classes and interfaces"
def package=(string)
  @package = string
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

# Prints undefined property and function calls; also performs compile-time type checking on assignments and options supplied to method calls.
# 
# The default value is true.
# 
# For more information about viewing warnings and errors, see Viewing warnings and errors (http://livedocs.adobe.com/flex/2/docs/00001517.html#182413).
def strict=(boolean)
  @strict = boolean
end

# The path to the ASDoc template directory. The default is the asdoc/templates directory in the ASDoc installation directory. This directory contains all the HTML, CSS, XSL, and image files used for generating the output.
def templates_path=(paths)
  @templates_path = paths
end

# Enables all warnings. Set to false to disable all warnings. This option overrides the warn-warning_type options.
# 
# The default value is true.
def warnings=(boolean)
  @warnings = boolean
end

# The text that appears in the browser window in the output documentation.
# 
# The default value is "API Documentation".
def window_title=(string)
  @window_title = string
end

end
end
