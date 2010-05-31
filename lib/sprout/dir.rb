
class Dir

  ##
  # Return true if the directory has no children.
  # 
  # Code found here: http://www.ruby-forum.com/topic/84762
  def empty?
    Dir.glob("#{ path }/*", File::FNM_DOTMATCH) do |e|
      return false unless %w( . .. ).include?(File::basename(e))
    end
    return true
  end

  ##
  # Return true if the provided path has no children.
  # 
  # Code found here: http://www.ruby-forum.com/topic/84762
  def self.empty? path
    new(path).empty?
  end
end

