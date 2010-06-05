
class TempGenerator < Sprout::Generator::Base

  add_param :source, String, { :default => 'src' }

  set :name, :demo
  set :pkg_name, 'temp_generator'
  set :pkg_version, '1.0.pre'

  def manifest
    directory input do
      directory source do
        template 'Main.as'
      end
    end
  end

  private

  def class_name
    input.camel_case
  end
end

