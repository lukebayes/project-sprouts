
class SongGenerator < Sprout::Generator::Base
  ##
  # Set your favorite song name:
  add_param :favorite, String, { :default => 'Emerge' }

  ##
  # Define your generator directories, files and templates:
  def manifest
    template "#{favorite_cleaned}.txt", 'Song.txt'
  end

  protected

  # helper methods will be available to templates too:
  def favorite_cleaned
    favorite.gsub(' ', '').snake_case
  end
end

