
class ProjectGenerator < Sprout::Generator::NamedBase # :nodoc:

  def manifest
    record do |m|
      base = class_name
      m.directory base
      m.directory File.join(base, 'assets/skins', project_name)
      m.directory File.join(base, 'bin')
      m.directory File.join(base, 'lib')
      m.directory File.join(base, 'script')
      m.directory File.join(base, 'src')
      m.directory File.join(base, 'test')

      m.file 'ProjectSprouts.png', File.join(base, 'assets/skins', project_name, 'ProjectSprouts.png')
      m.template 'rakefile.rb', File.join(base, "rakefile.rb")
      m.template 'README.txt', File.join(base, "README.txt")

      m.template 'generate', generate_script_path, :chmod => 0755
      m.template 'DefaultSkin.as', File.join(base, 'assets/skins', project_name + "Skin.as")

      m.template 'MainClass.as', File.join(base, 'src', "#{class_name}.as")
      m.template 'TestRunner.as', File.join(base, 'src', "#{class_name}Runner.as")
      m.template 'XMLRunner.as', File.join(base, 'src', "#{class_name}XMLRunner.as")
    end
  end

  protected
  # Not sure about the banner...
#    def banner
#      "Usage: #{$0} #{spec.name} ModelName [field:type, field:type]"
#    end

    def add_options!(opt)
      opt.on('-m', '--mxml', "Create a Flex project") { |v| options[:mxml] = true }
#      opt.on("--skip-migration", 
#             "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }
#      opt.on("--skip-fixture",
#             "Don't generation a fixture file for this model") { |v| options[:skip_fixture] = v}
      super

    end

end
