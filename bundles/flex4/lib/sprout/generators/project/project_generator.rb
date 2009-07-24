
class ProjectGenerator < Sprout::Generator::NamedBase # :nodoc:

  def manifest
    record do |m|
      base = class_name
      m.directory base
      m.directory File.join(base, 'assets/skins', project_name)
      m.directory File.join(base, 'bin')
      m.directory File.join(base, 'skins/default')
      m.directory File.join(base, 'lib')
      m.directory File.join(base, 'script')
      m.directory File.join(base, 'src')
      m.directory File.join(base, 'test')

      m.file 'ProjectSprouts.png', File.join(base, 'assets/skins', project_name, 'ProjectSprouts.png')
      m.template 'rakefile.rb', File.join(base, "rakefile.rb")
      m.template 'README.txt', File.join(base, "README.txt")

      m.template 'generate', generate_script_path, :chmod => 0755

      m.template 'MainStyle.css', File.join(base, 'src', "#{class_name}Skin.css")
      m.template 'MainClass.mxml', File.join(base, 'src', "#{class_name}.mxml")
      m.template 'TestRunner.mxml', File.join(base, 'src', "#{class_name}Runner.mxml")
      m.template 'XMLRunner.mxml', File.join(base, 'src', "#{class_name}XMLRunner.mxml")
    end
  end

end
