require 'sprout/fcsh_socket'

namespace :fcsh do

  desc "Start FCSH Service"
  task :start do
    Sprout::FCSHSocket.server
  end
  
end
