require 'git'
require 'file_util'

module Cherrybase
  class Baser
    
    def initialize(git = Cherrybase::Git.new, file_util = Cherrybase::FileUtil.new)
      @git = git
      @file_util = file_util
    end
    
    def init(branch_name, starting_commit, ending_commit)
      use_svn_commit = starting_commit && starting_commit.upcase == 'SVN'
      
      raise "Could not locate .git folder! Is this a Git repository?" if !@file_util.git_repo?
      raise "Could not find branch (#{branch_name}) in the Git repository" if !@git.has_branch?(branch_name)
      raise "It appears you are already in the middle of a cherrybase!?" if @file_util.temp_file?      
      raise "Could not locate START hash (#{starting_commit}) in the Git repository history" if !use_svn_commit && !@git.has_commit?(branch_name, starting_commit)
      raise "Could not locate END hash (#{ending_commit}) in the Git repository history" if ending_commit != nil && !@git.has_commit?(branch_name, ending_commit)      
      
      if (use_svn_commit)
        first_commit = @git.last_svn_commit(branch_name)
      else
        first_commit = @git.resolve_commit(branch_name, starting_commit)
      end
      
      if (ending_commit)
        last_commit = @git.resolve_commit(branch_name, ending_commit)
      else
        last_commit = @git.last_commit(branch_name)
      end
      
      commits = @git.commits_to_cherrypick(branch_name, first_commit, last_commit)
      
      if (use_svn_commit)
        commits.delete_at(0)
      end
      
      @file_util.write_temp_file(@git.last_commit(@git.current_branch), commits[0], commits)
    end
    
    def continue(commit_previous_hash = false)
      raise "It appears you are not in the middle of a cherrybase!?" if !@file_util.temp_file?
      
      temp_data = @file_util.read_temp_file()
      commits = temp_data['commits']
      next_cherrypick = temp_data['next_cherrypick']
      
      if commit_previous_hash
        raise "Please stage all your changes before trying to --continue" if @git.has_conflicts?
        commit_hash = commits.last
        if next_cherrypick
          commit_hash = commits[commits.index(next_cherrypick) - 1]
        end
        @git.commit(commit_hash)
      end
      
      if next_cherrypick
        conflicts_found = false
        last_commit_applied = nil
        i = commits.index(next_cherrypick)
      
        while i < commits.length
          puts "Applying #{i+1} of #{commits.length} cherry-picks" 
          last_commit_applied = commits[i]
          @git.cherry_pick(last_commit_applied)
          if @git.has_conflicts?
            conflicts_found = true
            break
          end
          i += 1
        end
      end
      
      if conflicts_found
        puts "Conflict(s) Encountered!"
        @git.status
        @file_util.write_temp_file(temp_data['starting_commit'], commits[i+1], commits)
      else
        @file_util.delete_temp_file()
        puts "Cherrybase completed!"
      end
    end
    
    def abort()
      raise "It appears you are not in the middle of a cherrybase!?" if !@file_util.temp_file?
      temp_data = @file_util.read_temp_file()
      @git.reset(temp_data['starting_commit'])
      @file_util.delete_temp_file()
    end
    
  end
end