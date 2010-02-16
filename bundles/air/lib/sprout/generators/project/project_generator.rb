
class ProjectGenerator < Sprout::Generator::NamedBase # :nodoc:

  def manifest
    record do |m|
      base = class_name
      m.directory base
      m.directory File.join(base, 'bin')
      m.directory File.join(base, 'bin-debug')
      m.directory File.join(base, 'package')
      m.directory File.join(base, 'script')
      m.directory File.join(base, 'src')
      m.directory File.join(base, 'src/assets/')
      m.directory File.join(base, 'src/assets/skins', project_name)
      m.directory File.join(base, 'lib')
      m.directory File.join(base, 'cert')
      m.directory File.join(base, 'doc')

      m.file 'ProjectSprouts.png', File.join(base, 'src/assets/skins', project_name, 'ProjectSprouts.png')
      m.template 'rakefile.rb', File.join(base, "rakefile.rb")
      m.template 'README.txt', File.join(base, "README.txt")

      m.template 'generate', generate_script_path, :chmod => 0755

      m.template 'META/Application-app.xml', File.join(base, 'src', "#{class_name}-app.xml")
      m.template 'META/Application-Debug-app.xml', File.join(base, 'src', "#{class_name}-Debug-app.xml")
      m.template 'MainStyle.css', File.join(base, 'src', "#{class_name}Skin.css")
      m.template 'MainClass.mxml', File.join(base, 'src', "#{class_name}.mxml")

      m.template 'META/cert.p12', File.join(base, 'cert', "cert.p12")
      m.template 'META/cert_readme.txt', File.join(base, 'cert', "cert_readme.txt")

    end
  end

end
