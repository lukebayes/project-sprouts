
module Sprout
  module Library
    include RubyFeature

    class << self

      ##
      # Create Rake tasks that will load and install
      # a particular library.
      def define_task pkg_name, type=nil, version=nil
        lib = Sprout::Library.load type, pkg_name.to_s, version
        installation_path = "lib/#{pkg_name}"
        if(File.directory?(lib.path))
          task_name = installation_path
          # Create a file task to copy the library source files:
          file task_name do
            FileUtils.cp_r lib.path, installation_path
            Sprout::Log.puts ">> Copied file(s) from: (#{lib.path}) to: (#{installation_path})"
          end
          task :sprout_libraries => installation_path
        else
          task_name = "#{installation_path}/#{File.basename(lib.path)}"
          file task_name do
            FileUtils.mkdir_p installation_path
            FileUtils.cp lib.path, "#{installation_path}/"
            Sprout::Log.puts ">> Created file(s) from: (#{lib.path}) to: (#{task_name})"
          end
        end

        # Associate this library with then :resolve_libraries task
        task :resolve_libraries => task_name
      end
    end

  end
end

# From within a Rakefile, you can load libraries
# by calling this shortcut:
#
#   library :asunit4
#
# Or, if you would like to specify which registered
# library to pull from the identified package:
#
#   library :asunit4, :src
#
# Or, if you'd like to specify the version:
#
#   library :asunit4, :swc, '>= 4.2.pre'
#
def library pkg_name, type=nil, version=nil
  Sprout::Library.define_task pkg_name, type, version
end

