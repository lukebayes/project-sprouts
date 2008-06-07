module Sprout
class MTASCTask < ToolTask
# Add a directory path to the class path. This is the list of directories that MTASC will use to look for .as files. You can add as many class_path values as you like. This parameter is an Array, so be sure to append rather than overwrite.
# 
# Even though the official MTASC compiler accepts the +cp+ paramter, we have aliased it as +class_path+, you can use either name in your scripts.
# 
#   mtasc 'bin/SomeProject.swf' do |t|
#     t.class_path << 'lib/somelib'
#     t.class_path << 'lib/otherlib'
#     # The following is not correct:
#     # t.class_path = 'lib/somelib'
#   end
def cp=(paths)
  @cp = paths
end

# Exclude code generation of classes listed in specified file (format is one full class path per line).
def exclude=(file)
  @exclude = file
end

# Export AS2 classes into target frame of swf.
def frame=(number)
  @frame = number
end

# Merge classes into one single clip (this will reduce SWF size but might cause some problems if you're using -keep or -mx).
def group=(boolean)
  @group = boolean
end

# width:height:fps:bgcolor: Create a new swf containing only compiled code and using provided header informations. bgcolor is optional and should be 6 digits hexadecimal value.
def header=(string)
  @header = string
end

# Add type inference for initialized local variables.
def infer=(boolean)
  @infer = boolean
end

# Keep AS2 classes compiled by MCC into the SWF (this could cause some classes to be present two times if also compiled with MTASC).
def keep=(boolean)
  @keep = boolean
end

# Will automaticaly call static function main once all classes are registered.
def main=(boolean)
  @main = boolean
end

# Use Microsoft Visual Studio errors style formating instead of Java style (for file names and line numbers).
def msvc=(boolean)
  @msvc = boolean
end

# Use precompiled MX classes (see section on V2 components below).
def mx=(boolean)
  @mx = boolean
end

# The SWF file that should be generated, use only in addition to the -swf parameter if you want to generate a separate SWF from the one being loaded
def out=(file)
  @out = file
end

# Compile all the files contained in specified package - not recursively (eg to compile files in c:lashdemypp do mtasc -cp c:lashde -pack my/app).
def pack=(paths)
  @pack = paths
end

# Use strict compilation mode which require that all variables are explicitely typed.
def strict=(boolean)
  @strict = boolean
end

# Specify the swf that should be generated, OR the input SWF which contains assets.
# 
# If this parameter is not set, the MTASCTask will do the following:
# * Iterate over it's prerequisites and set the -swf parameter to the output of the first SWFMillTask found
# * If no SWFMillTask instances are in this task prerequisites and the -swf parameter has not been set, it will be set to the same as the -out parameter
def swf=(file)
  @swf = file
end

# Specify a custom trace function. (see Trace Facilities), or no disable all the traces.
def trace=(string)
  @trace = string
end

# Specify SWF version : 6 to generate Player 6r89 compatible SWF or 8 to access Flash8 features.
def version=(number)
  @version = number
end

# Activate verbose mode, printing some additional information about compiling process. This parameter has been aliased as +verbose+
def v=(boolean)
  @v = boolean
end

# Adds warnings for import statements that are not used in the file.
def wimp=(boolean)
  @wimp = boolean
end

# Main source file to send compiler
def input=(file)
  @input = file
end

end
end
