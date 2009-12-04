module Cherrybase
  DEBUG = false
  
  class Cmd
    def run(command)
      if DEBUG
        puts "[Cmd::run] #{command}"
      end
      lines = IO.popen(command).readlines
      if DEBUG
        lines.each do |line|
          puts "[Cmd::result] #{line}"
        end
      end
      lines
    end
  end
end