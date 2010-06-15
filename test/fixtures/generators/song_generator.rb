
class SongGenerator < Sprout::Generator::Base

  add_param :favorite, String, { :default => 'Emerge' }

  def manifest
    template "#{favorite.gsub(' ', '').snake_case}.txt", 'Song.txt'
  end

end

