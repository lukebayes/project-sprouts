
class LeastFavorite < SongGenerator

  def manifest
    directory 'sucky' do
      super
    end
  end
end

