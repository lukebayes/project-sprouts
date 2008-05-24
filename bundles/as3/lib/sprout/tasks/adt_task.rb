module Sprout
    
  # The ADT Task provides Rake support for the AIR Developer Tool package command.
  # http://livedocs.adobe.com/flex/3/html/CommandLineTools_5.html#1035876
  #
  # The following example can be pasted in a file named 'rakefile.rb':
  #
  #   # Create an ADL task named :run dependent upon the swf that it is using for the window content
  #   adt :package => 'SomeProject.swf' do |t|
  #     t.storetype = "PKCS12"
  #     t.keystore = "cert.p12"
  #     t.output = "bin/TestProj.air"
  #     t.application_descriptor = "src/SomeProject-app.xml"
  #     t.files = [ "assets", "skins" ]
  #   end
  #
  class ADTTask < ToolTask
    

    def initialize_task
      super
      @default_gem_name = 'sprout-flex3sdk-tool'
      @default_gem_path = 'bin/adt'

      # Package command is "adt -package"
      add_param(:package, :boolean) do |p|
        p.description = "Using -package option as default."
        p.value = true
        p.hidden_value = true
      end

      #
      # Signing options
      #
      
      add_param(:alias, :string) do |p|
        p.delimiter = " "
        p.description = <<-DESC
        The alias of a key in the keystore. Specifying an alias is not 
        necessary when a keystore only contains a single certificate. If no 
        alias is specified, ADT uses the first key in the keystore.
        DESC
      end
      
      add_param(:storetype, :string) do |p|
        p.delimiter = " "
        p.description = <<-DESC
        The type of keystore, determined by the keystore implementation. The 
        default keystore implementation included with most installations of 
        Java supports the JKS and PKCS12 types. Java 5.0 includes support for 
        the PKCS11 type, for accessing keystores on hardware tokens, and 
        Keychain type, for accessing the Mac OS-X keychain. Java 6.0 includes 
        support for the MSCAPI type (on Windows). If other JCA providers have 
        been installed and configured, additional keystore types might be 
        available. If no keystore type is specified, the default type for the 
        default JCA provider is used.
        DESC
      end
      
      add_param(:providerName, :string) do |p|
        p.delimiter = " "
        p.description = <<-DESC
        The JCA provider for the specified keystore type. If not specified, 
        then ADT uses the default provider for that type of keystore.
        DESC
      end      
      
      add_param(:keystore, :file) do |p|
        p.delimiter = " "
        p.description = "The path to the keystore file for file-based store types."
      end
      
      add_param(:storepass, :string) do |p|
        p.delimiter = " "
        p.description = <<-DESC
        The password required to access the keystore. If not specified, ADT 
        prompts for the password.
        DESC
      end
      
      add_param(:keypass, :string) do |p|
        p.delimiter = " "
        p.description = <<-DESC
        The password required to access the private key that will be used to 
        sign the AIR application. If not specified, ADT prompts for the password.
        DESC
      end
      
      add_param(:tsa, :url) do |p|
        p.delimiter = " "
        p.description = <<-DESC
        Specifies the URL of an RFC3161-compliant time stamp server to time 
        stamp the digital signature. If no URL is specified, a default time 
        stamp server provided by Geotrust is used. When the signature of an AIR
        application is time stamped, the application can still be installed 
        after the signing certificate expires, because the time stamp verifies 
        that the certificate was valid at the time of signing. 
        DESC
      end
      
      #
      # ADT package options
      #

      add_param(:output, :file) do |p|
        p.hidden_name = true
        p.required = true
        p.description = "The name of the AIR file to be created."
      end
      
      add_param(:application_descriptor, :file) do |p|
        p.hidden_name = true
        p.delimiter = " "
        p.required = true
        p.description = <<-DESC
        The path to the application descriptor file. The path can be specified 
        relative to the current directory or as an absolute path. (The 
        application descriptor file is renamed as "application.xml" in the AIR 
        file.)
        DESC
      end

      add_param(:files, :files) do |p|
        # Work-around for shell name not being hidden on files param type
        p.instance_variable_set(:@shell_name, "")        
        p.hidden_name = true
        p.delimiter = ""        
        p.description = <<-DESC
        The files and directories to package in the AIR file. Any number of 
        files and directories can be specified, delimited by whitespace. If you
        list a directory, all files and subdirectories within, except hidden 
        files, are added to the package. (In addition, if the application 
        descriptor file is specified, either directly, or through wildcard or 
        directory expansion, it is ignored and not added to the package a 
        second time.) Files and directories specified must be in the current 
        directory or one of its subdirectories. Use the -C option to change the 
        current directory.
        DESC
      end

      def define # :nodoc:
        super

        if(!output)
          self.output = name
        end

        CLEAN.add(output)
      end
            
    end
  end
  
  # The ADT Cert Task provides Rake support for the AIR Developer Tool certificate command.
  # http://livedocs.adobe.com/flex/3/html/CommandLineTools_6.html#1034775
  #
  # The certificate and associated private key generated by ADT are stored in a PKCS12-type keystore file. 
  # The password specified is set on the key itself, not the keystore.
  #
  # The following example can be pasted in a file named 'rakefile.rb':
  #
  #   # Create an ADL task named :run dependent upon the swf that it is using for the window content
  #   adt_cert :certificate do |t|
  #     t.cn = "Common name"
  #     t.keytype = "1024-RSA"
  #     t.keystore = "cert.p12"
  #     t.keypass = "thepassword"
  #   end
  #
  class ADTCertTask < ToolTask

    def initialize_task
      super
      @default_gem_name = 'sprout-flex3sdk-tool'
      @default_gem_path = 'bin/adt'

      # Certificate command is "adt -certificate"
      add_param(:certificate, :boolean) do |p|
        p.description = "Using -certificate option as default."
        p.value = true
        p.hidden_value = true
      end
      
      add_param(:cn, :string) do |p|
        p.required = true
        p.delimiter = " "
        p.description = "The string assigned as the common name of the new certificate."
      end
      
      add_param(:ou, :string) do |p|
        p.delimiter = " "
        p.description = "Astring assigned as the organizational unit issuing the certificate."
      end
      
      add_param(:o, :string) do |p|
        p.delimiter = " "
        p.description = "A string assigned as the organization issuing the certificate."
      end
      
      add_param(:c, :string) do |p|
        p.delimiter = " "
        p.description = "A two-letter ISO-3166 country code. A certificate is not generated if an invalid code is supplied."
      end
      
      add_param(:keytype, :string) do |p|
        p.hidden_name = true
        p.required = true
        p.description = %{The type of key to use for the certificate, either "1024-RSA" or "2048-RSA".}
      end
      
      add_param(:keystore, :file) do |p|
        p.hidden_name = true
        p.required = true
        p.description = "The path for the certificate file to be generated."
      end
      
      add_param(:keypass, :string) do |p|
        p.hidden_name = true
        p.required = true
        p.description = "The password for the new certificate. The password is required when signing AIR files with this certificate."
      end      
    end
    
    def prepare
      super
      # In case of spaces, need to escape them. Maybe have an option on StringParam to do this for us?
      cn.gsub!(/\s/, "\\ ") if cn
      ou.gsub!(/\s/, "\\ ") if ou
      o.gsub!(/\s/, "\\ ") if o
    end
    
  end
  
end

# Helper method for definining and accessing ADLTask instances in a rakefile
def adt(args, &block)
  Sprout::ADTTask.define_task(args, &block)
end

def adt_cert(args, &block)
  Sprout::ADTCertTask.define_task(args, &block)
end


