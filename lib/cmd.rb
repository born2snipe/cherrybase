module Cherrybase
  DEBUG = false
  
  class Cmd
    def run(command = '', show_lines = false)
      if DEBUG
        puts "[Cmd::run] #{command}"
      end
      lines = IO.popen(command).readlines
      if DEBUG || show_lines
        lines.each do |line|
          puts line
        end
      end
      lines
    end
  end
end