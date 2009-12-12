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
      
      last_commit = @git.last_commit(branch_name)
      commits = @git.commits_to_cherrypick(starting_commit, last_commit)
      @file_util.write_temp_file(starting_commit, starting_commit, commits)
    end
    
    def continue()
    end
    
    def abort()
    end
    
    def x(branch_name, starting_commit, ending_commit)
      raise "Could not locate .git folder! Is this a Git repository?" if !@file_util.git_repo?
      
      @root_git_dir = @file_util.git_root_dir()
      temp_file_info = @file_util.temp_file()
      if temp_file_info
        @initial_commit = temp_file_info['initial_commit']
        @commits_to_cherrypick = temp_file_info['commits_to_cherrypick']
        @next_cherrypick = temp_file_info['next_cherrypick']
      else
        @initial_commit = @git.last_svn_commit()
        @commits_to_cherrypick = @git.commits_to_cherrypick()
        @next_cherrypick = @commits_to_cherrypick[0]
        @file_util.write_temp_file(@root_git_dir, @initial_commit, @next_cherrypick, @commits_to_cherrypick)
      end
    end
    
    
  end
end