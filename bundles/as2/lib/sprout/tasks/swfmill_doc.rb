module Sprout
class SWFMillTask < ToolTask
# Set the SWFMill simple flag. This setting will determine what kind of xml document the compiler expects. Unless you really know what you're doing with SWFMill, this setting will usually be left alone.
def simple=(boolean)
  @simple = boolean
end

# The input can be one of the following
#  * SWFMill XML document: Create and manually manage an input file as described at http://www.swfmill.org
#  * Directory: if you point at a directory, this task will automatically include all files found forward of that directory. As it descends into child directories, the items found will be exposed in the library using period delimiters as follows:
# 
# The file:
#   yourcompany/yourproject/SomeFile.png
# Will be available in the compiled swf with a linkage identifier of:
#   yourcompany.yourproject.SomeFile
def input=(string)
  @input = string
end

# The output parameter should not be set from outside of this task, the output file should be the task name
def output=(file)
  @output = file
end

# An ERB template to send to the generated SWFMillInputTask. This template can be used to generate an XML input document based on the contents of a directory. If no template is provided, one will be created for you after the first run, and once created, you can configure it however you wish.
def template=(file)
  @template = file
end

end
end
