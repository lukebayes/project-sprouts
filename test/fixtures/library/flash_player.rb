
class FlashPlayer
  include Sprout::Tool

  file_target :windows do |t|
    t.url = "http://adobe.com/win/flashplayer"
    t.md5 = "abcd"
    t.archive_type = :zip
    t.add_executable :flashplayer, "adobe/FlashPlayer.exe"
  end

  file_target :darwin do |t|
    t.url = "http://adobe.com/darwin/flashplayer"
    t.md5 = "efgh"
    t.archive_type = :tgz
    t.add_executable :flashplayer, "adobe/FlashPlayer.app/MacOS/flashplayer"
  end

  file_target :linux do |t|
    t.url = "http://adobe.com/linux/flashplayer"
    t.md5 = "ijkl"
    t.archive_type = :tgz
    t.add_executable :flashplayer, "adobe/flashplayer"
  end

end

#path_to_exe = FlashPlayer.executable

