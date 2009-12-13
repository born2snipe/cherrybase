require 'cmd'

module Cherrybase
  class Git
    def initialize(cmd = Cherrybase::Cmd.new)
      @cmd = cmd
    end
    
    def unstaged_files?()
      false
    end
    
    def reset(commit_hash)
      @cmd.run("git reset --hard #{commit_hash}")
    end
    
    def has_commit?(branch_name, commit_hash)
      resolve_commit(branch_name, commit_hash) != nil
    end
    
    def resolve_commit(branch_name, commit_hash)
      if commit_hash
        raise "Please supply at least 5 characters for a commit hash" if commit_hash.length < 5
        match = nil
        @cmd.run("git log #{branch_name} --pretty=oneline").each do |line|
          if line == commit_hash || line.include?(commit_hash)
            raise "Ambigous hash commit found! Please supply more of the commit hash (#{commit_hash})" if match
            match = line.split(' ')[0]
          end
        end
        match
      else
        nil
      end
    end
    
    def last_commit(branch_name)
      lines = @cmd.run("git log #{branch_name} --pretty=oneline")
      if (lines.length > 0)
        lines[0].split(' ')[0]
      else
        nil
      end
    end
    
    def cherry_pick(commit_hash)
      @cmd.run("git cherry-pick #{commit_hash}")
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
    
    def current_branch()
      @cmd.run("git branch").each do |line|
        if line.index('*')
          return line.gsub(/\*(.+)/, '\1').strip
        end
      end
      nil
    end
    
    def has_branch?(branch_name)
      @cmd.run("git branch").each do |line|
        if line.strip == branch_name
          return true
        end
      end
      false
    end
    
    def commits_to_cherrypick(branch_name, first_commit = nil, last_commit = nil)
      commits = []
      @cmd.run("git log #{branch_name} --pretty=oneline").each do |line|
        commit_hash = line.split(' ')[0]
        if commit_hash == first_commit
          commits << commit_hash
          break
        else
          commits << commit_hash
        end
      end
      
      if last_commit
        remove_commits = []
        commits.each do |commit|
          if  commit == last_commit
             break
          else
             remove_commits << commit
          end
      end
      commits = commits - remove_commits
     end
     
     commits.reverse
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