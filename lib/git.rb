module Cherrybase
  class Git
    def initialize(cmd)
      @cmd = cmd
    end
    
    def has_conflicts?()
      @cmd.run("git ls-files -tu").length > 0
    end
    
    def commit(commit_hash)
      @cmd.run("git commit -C #{commit_hash}")
    end
    
    def status()
      @cmd.run("git status", true)
    end
    
    def commits_to_cherrypick()
      commits = []
      last_svn_commit = last_svn_commit()
      @cmd.run("git log --pretty=oneline").each do |line|
        commit_hash = line.split(' ')[0]
        if last_svn_commit == commit_hash
          break
        else
          commits << commit_hash
        end
      end        
      commits
    end
    
    def last_svn_commit()
      last_commit_hash = nil
      svn_commit_found = false
      @cmd.run("git log").each do |line|
        if line.include?("git-svn-id")
          svn_commit_found = true
          break
        else
          if line =~ /commit [a-z0-9]+$/
            last_commit_hash = line[7,line.length]
          end
        end
      end
      if (!svn_commit_found)
        last_commit_hash = nil
      end
      last_commit_hash
    end
  end
end