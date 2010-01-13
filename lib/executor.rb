require 'args'
require 'baser'

module Cherrybase
  class Executor
    def initialize(baser = Cherrybase::Baser.new)
      @baser = baser
    end
    
    def execute(args)
      begin
        input = Cherrybase::Args.new().parse(args)
        if (input['continue'])
          @baser.continue(true)
        else
          if (input['abort'])
            @baser.abort
          else
            if input['help']
              showHelp()
            else
              @baser.init(input['branch'], input['starting-commit'], input['ending-commit'])
              @baser.continue
            end
          end
        end
      rescue RuntimeError => err
        puts "\n#{err}\n\n" 
        showUsage()
      end
    end
    
    def showUsage() 
      puts "Usage: cherrybase [<branch> [<commit> | <commit>..<commit> | svn | svn..<commit>]] | --continue | --abort"
    end
    
    def showHelp()
        puts "NAME"
        puts "\tcherrybase - cherry-pick a range of commits from one branch to the current branch"
        puts "SYNOPSIS"
        puts "\tshowUsage()"
        puts "DESCRIPTION"
        puts "\tThe idea is to cherry-pick across multiple commits and have similar functionality as the rebase command."
    end
    
  end
end