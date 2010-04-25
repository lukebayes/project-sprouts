
Sprout::Specification.new do |s|
  s.name        = "flashplayer"
  s.version     = "10.1.pre"
  s.authors     = ["Luke Bayes"]
  s.email       = ["projectsprouts@googlegroups.com"]
  s.homepage    = "http://www.adobe.com/support/flashplayer/downloads.html"
  s.summary     = "The Adobe Flash Player"
  s.description = "Flash Player is a cross-platform browser plug-in that delivers breakthrough Web experiences to over 99% of Internet users."

  s.add_remote_file_target do |t|
    t.platform     = :macosx
    t.archive_type = :zip
    t.url          = "http://download.macromedia.com/pub/flashplayer/updaters/10/flashplayer_10_sa_debug.app.zip"
    t.md5          = "fb998833d0faf11f0c4f412643f63d3f"
    t.add_executable :flashplayer, "Flash Player.app/Contents/MacOS/Flash Player"
  end 

  s.add_remote_file_target do |t|
    t.platform     = :win32
    t.archive_type = :exe
    t.url          = "http://download.macromedia.com/pub/flashplayer/updaters/10/flashplayer_10_sa_debug.exe"
    t.md5          = "c364068fad3fed190983845a35e4ccdc"
    t.add_executable :flashplayer, "flashplayer_10_sa_debug.exe"
  end 

  s.add_remote_file_target do |t|
    t.platform     = :linux
    t.archive_type = :tgz
    t.url          = "http://download.macromedia.com/pub/flashplayer/updaters/10/flash_player_10_linux_dev.tar.gz"
    t.md5          = "67f5081cf7d122063b332ea3e59d838b"
    t.add_executable :flashplayer, "flash_player_10_linux_dev/standalone/debugger/flashplayer"
  end 
end

