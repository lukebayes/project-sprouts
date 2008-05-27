
class ToolGeneratorError < StandardError #:nodoc:
end

# Generate a new Sprout tool project. 
# This generator can be executed as follows:
# 
#   sprout -n developer Flex3SDK
#
class ToolGenerator < Sprout::Generator::NamedBase # :nodoc:
  
  def manifest
    record do |m|
      # Create outer directory
      m.directory tool_name
      m.directory File.join(tool_name, 'bin') unless executables.size == 0

      # Create rakefile
      m.template 'rakefile.erb', File.join(tool_name, 'rakefile.rb')

      # Create version.rb file
      version_path = File.join(tool_name, 'lib', 'sprout', tool_name)
      m.directory version_path
      m.template 'version.erb', File.join(version_path, 'version.rb')
      
      # Copy sprout.spec to new project
      new_spec = File.join(tool_name, 'sprout.spec')
      m.template 'sprout.spec', new_spec
      
      # Create rubygem binaries for each executable
      executables.each do |binary|
        target = File.join(tool_name, 'bin', File.basename(binary))
        m.template 'binary.erb', target, :assigns => { :binary => binary }
      end
    end
  end
  
  def gem_version
    options[:gem_version]
  end
  
  def executables
    options[:executables]
  end
  
  def sprout_spec
    options[:sprout_spec]
  end
  
  def major_version
    gem_version.split('.')[0]
  end
  
  def minor_version
    gem_version.split('.')[1]
  end
  
  def tiny_version
    gem_version.split('.')[2]
  end
  
  def tool_name
    @tool_name ||= class_name.downcase
  end

  protected
  # Override with your own usage banner.
  def banner
    "Usage: #{$0} tool toolname --exe path_to_exe [--version gem_version, --exe path_to_another_exe]"
  end
  
  def options
    options ||= default_options
  end
  
  def add_options!(opt)
    super
    options[:gem_version] = '0.0.0'
    options[:executables] = []
    options[:sprout_spec] = ''

    opt.separator ''
    opt.separator 'Options:'
    opt.on("-g", "--gem-version=VERSION", String,
            "The version of the tool (e.g., 1.0.0)"
            ) do |version|
              options[:gem_version] = version
            end
    opt.on("-e", "--exe=EXECUTABLE", String,
            "Add the relative path, from the archive root, to an executable (e.g., --exe bin/mxmlc --exe bin/asdoc --exe bin/fdb)"
            ) do |exe|
              options[:executables] << exe
            end
    opt.on("-s", "--sprout-spec=SPEC", String,
            "Path to sprout.spec file"
            ) do |spec|
              spec = File.expand_path(spec)
              raise ToolGeneratorError.new("Provided spec file does not exist #{spec}") unless File.exists?(spec)
              options[:sprout_spec] = File.open(spec, 'r').read
            end
  end

end
