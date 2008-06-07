module Sprout
class ADTTask < ToolTask
# Using -package option as default.
def package=(boolean)
  @package = boolean
end

#         The alias of a key in the keystore. Specifying an alias is not 
#         necessary when a keystore only contains a single certificate. If no 
#         alias is specified, ADT uses the first key in the keystore.
def alias=(string)
  @alias = string
end

#         The type of keystore, determined by the keystore implementation. The 
#         default keystore implementation included with most installations of 
#         Java supports the JKS and PKCS12 types. Java 5.0 includes support for 
#         the PKCS11 type, for accessing keystores on hardware tokens, and 
#         Keychain type, for accessing the Mac OS-X keychain. Java 6.0 includes 
#         support for the MSCAPI type (on Windows). If other JCA providers have 
#         been installed and configured, additional keystore types might be 
#         available. If no keystore type is specified, the default type for the 
#         default JCA provider is used.
def storetype=(string)
  @storetype = string
end

#         The JCA provider for the specified keystore type. If not specified, 
#         then ADT uses the default provider for that type of keystore.
def providerName=(string)
  @providerName = string
end

# The path to the keystore file for file-based store types.
def keystore=(file)
  @keystore = file
end

#         The password required to access the keystore. If not specified, ADT 
#         prompts for the password.
def storepass=(string)
  @storepass = string
end

#         The password required to access the private key that will be used to 
#         sign the AIR application. If not specified, ADT prompts for the password.
def keypass=(string)
  @keypass = string
end

#         Specifies the URL of an RFC3161-compliant time stamp server to time 
#         stamp the digital signature. If no URL is specified, a default time 
#         stamp server provided by Geotrust is used. When the signature of an AIR
#         application is time stamped, the application can still be installed 
#         after the signing certificate expires, because the time stamp verifies 
#         that the certificate was valid at the time of signing. 
def tsa=(url)
  @tsa = url
end

# The name of the AIR file to be created.
def output=(file)
  @output = file
end

#         The path to the application descriptor file. The path can be specified 
#         relative to the current directory or as an absolute path. (The 
#         application descriptor file is renamed as "application.xml" in the AIR 
#         file.)
def application_descriptor=(file)
  @application_descriptor = file
end

#         The files and directories to package in the AIR file. Any number of 
#         files and directories can be specified, delimited by whitespace. If you
#         list a directory, all files and subdirectories within, except hidden 
#         files, are added to the package. (In addition, if the application 
#         descriptor file is specified, either directly, or through wildcard or 
#         directory expansion, it is ignored and not added to the package a 
#         second time.) Files and directories specified must be in the current 
#         directory or one of its subdirectories. Use the -C option to change the 
#         current directory.
def files=(files)
  @files = files
end

end
end
