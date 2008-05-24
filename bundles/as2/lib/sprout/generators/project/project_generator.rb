
# Generate a new ActionScript 2.0 Project
# This generator can be executed as follows:
# 
#   sprout -n as2 SomeProject
#
class ProjectGenerator < Sprout::Generator::NamedBase # :nodoc:

  def manifest
    record do |m|
      base = class_name
      m.directory base
      m.directory File.join(base, 'assets/skins', project_name + 'Skin')
      m.directory File.join(base, 'bin')
      m.directory File.join(base, 'lib')
      m.directory File.join(base, 'script')
      m.directory File.join(base, 'src')
      m.directory File.join(base, 'test')

      m.file 'ProjectSprouts.png', File.join(base, 'assets/skins', project_name + 'Skin', 'ProjectSprouts.png')
      m.template 'rakefile.rb', File.join(base, "rakefile.rb")
      m.template 'README.txt', File.join(base, "README.txt")

      m.template 'generate', generate_script_path, :chmod => 0755

      m.template 'MainClass.as', File.join(base, 'src', "#{class_name}.as")
      m.template 'TestRunner.as', File.join(base, 'test', "#{class_name}Runner.as")
    end
  end
end
