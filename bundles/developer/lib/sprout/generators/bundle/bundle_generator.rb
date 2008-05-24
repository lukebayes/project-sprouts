
class BundleGenerator < Sprout::Generator::NamedBase # :nodoc:

  def manifest
    record do |m|
      base = class_name
      base_lower = base.downcase
      m.directory base_lower

#      m.directory File.join(base_lower, 'lib', 'sprout', base_lower)
#      m.directory File.join(base_lower, 'lib', 'sprout', 'generators')
      
#      m.directory File.join(base_lower, 'test', 'fixtures')

#      actions.each do |action|
#        m.directory File.join(base_lower, 'lib', 'sprout', 'generators', action)
#        m.template 'action_generator.erb', File.join(base_lower, 'lib', 'sprout', 'generators', action)
#        m.directory File.join(base_lower, 'lib', 'sprout', 'generators', action, 'templates')
#      end

    end
  end

=begin
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
=end

end
