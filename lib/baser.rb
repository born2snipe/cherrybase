require 'git'
require 'file_util'

module Cherrybase
  class Baser
    
    def initialize(git = Cherrybase::Git.new, file_util = Cherrybase::FileUtil.new)
      @git = git
      @file_util = file_util
    end
    
    def init(branch_name, starting_commit, ending_commit)
      raise "Could not locate .git folder! Is this a Git repository?" if !@file_util.git_repo?
      raise "Could not find branch (#{branch_name}) in the Git repository" if !@git.has_branch?(branch_name)
      raise "It appears you are already in the middle of a cherrybase!?" if @file_util.temp_file?      
      raise "Could not locate START hash (#{starting_commit}) in the Git repository history" if !@git.has_commit?(branch_name, starting_commit)
      raise "Could not locate END hash (#{ending_commit}) in the Git repository history" if ending_commit != nil && !@git.has_commit?(branch_name, ending_commit)      
      
      # TODO - need to acknowlege teh ending_commit
      first_commit = @git.resolve_commit(branch_name, starting_commit)
      if (ending_commit)
        last_commit = @git.resolve_commit(branch_name, ending_commit)
      else
        last_commit = @git.last_commit(branch_name)
      end
      commits = @git.commits_to_cherrypick(branch_name, first_commit, last_commit)
      @file_util.write_temp_file(first_commit, first_commit, commits)
    end
    
    def continue(commit_previous_hash = false)
      raise "It appears you are not in the middle of a cherrybase!?" if !@file_util.temp_file?
      
      temp_data = @file_util.read_temp_file()
      commits = temp_data['commits']
      next_cherrypick = temp_data['next_cherrypick']
      
      if commit_previous_hash
        @git.commit(commits[commits.index(next_cherrypick) - 1])
      end
      
      conflicts_found = false
      last_commit_applied = nil
      i = commits.index(next_cherrypick)
      
      while i < commits.length
        print "Applying #{i+1} of #{commits.length} cherry-picks\r" 
        last_commit_applied = commits[i]
        @git.cherry_pick(last_commit_applied)
        if @git.has_conflicts?
          conflicts_found = true
          break
        end
        i += 1
      end
      print "\n"
      
      if conflicts_found
        puts "Conflict(s) Encountered!"
        @git.status
        if (last_commit_applied == commits.last)
          @file_util.delete_temp_file()
        else
          @file_util.write_temp_file(temp_data['starting_commit'], commits.last, commits)
        end
      else
        @file_util.delete_temp_file()
      end
      puts "Cherrybase completed!"
    end
    
    def abort()
    end
    
  end
end