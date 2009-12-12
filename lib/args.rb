module Cherrybase
  class Args
    def parse(args)
      if args.include?('--help')
        return {'help' => true}
      end
      
      result = {}
      
      if !args.include?('--continue') && !args.include?('--abort')
        raise "You must supply at least the branch name and the starting commit hash to begin cherrybasing" if args.length != 2
              
        result['branch'] = args[0]
        
        if args[1] =~ /[0-9a-z]+\.\.[0-9a-z]+/
          parts = args[1].split('..')
          result['starting-commit'] = parts[0]
          result['ending-commit'] = parts[1]
        else
          result['starting-commit'] = args[1]
        end
      else
        result['continue'] = args.include?('--continue')
        result['abort'] = args.include?('--abort')

        raise "You supplied --abort and --continue, please pick one" if result['continue'] && result['abort']
      end
      
      result
    end
  end
end