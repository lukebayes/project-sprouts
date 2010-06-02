
class TempGenerator < Sprout::Generator::Base

  add_param :source, String, { :default => 'src' }

  set :pkg_name, 'temp_generator'

  set :pkg_version, '1.0.pre'

  set :environment, :demo

  def manifest
    directory name do
      directory source do
        file 'Main.as'
      end
    end
  end

  private

  def class_name
    name.camel_case
  end
end

