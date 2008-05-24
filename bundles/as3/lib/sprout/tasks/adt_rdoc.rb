module Sprout
class ADLTask < ToolTask
#         Specifies the directory containing the runtime to use. If not 
#         specified, the runtime directory in the same SDK as the ADL program
#         will be used. If you move ADL out of its SDK folder, then you must 
#         specify the runtime directory. On Windows, specify the directory 
#         containing the Adobe AIR directory. On Mac OSX, specify the directory 
#         containing Adobe AIR.framework.
def runtime=(file)
  @runtime = file
end

#         Turns off debugging support. If used, the application process cannot 
#         connect to the Flash debugger and dialogs for unhandled exceptions are
#         suppressed. 
#         
#         Trace statements still print to the console window. Turning off 
#         debugging allows your application to run a little faster and also 
#         emulates the execution mode of an installed application more closely.
def nodebug=(boolean)
  @nodebug = boolean
end

#         Assigns the specified value as the publisher ID of the AIR application 
#         for this run. Specifying a temporary publisher ID allows you to test 
#         features of an AIR application, such as communicating over a local 
#         connection, that use the publisher ID to help uniquely identify an 
#         application. 
#         
#         The final publisher ID is determined by the digital certificate used to 
#         sign the AIR installation file.
def pubid=(string)
  @pubid = string
end

# The application descriptor file.
def application_descriptor=(file)
  @application_descriptor = file
end

#         The root directory of the application to run. If not 
#         specified, the directory containing the application 
#         descriptor file is used.
def root_directory=(file)
  @root_directory = file
end

#         Passed to the application as command-line arguments.
def arguments=(string)
  @arguments = string
end

end
end
