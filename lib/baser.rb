require 'git'
require 'file_util'

module Cherrybase
  class Baser
    attr_reader :last_svn_commit, :commits_to_cherrypick, :next_cherrypick
    
    def initialize(git = Cherrybase::Git.new, file_util = nil)
      @git = git
      @file_util = file_util
    end
    
    def init()
      raise "Could not locate .git folder! Is this a Git repository?" if !@file_util.git_repo?
      
      @root_git_dir = @file_util.git_root_dir()
      temp_file_info = @file_util.temp_file(@root_git_dir)
      if temp_file_info
        @last_svn_commit = temp_file_info['last_svn_commit']
        @commits_to_cherrypick = temp_file_info['commits_to_cherrypick']
        @next_cherrypick = temp_file_info['next_cherrypick']
      else
        @last_svn_commit = @git.last_svn_commit()
        @commits_to_cherrypick = @git.commits_to_cherrypick()
        @next_cherrypick = @commits_to_cherrypick[0]
        @file_util.write_temp_file(@root_git_dir, @last_svn_commit, @next_cherrypick, @commits_to_cherrypick)
      end
    end
    
    
  end
end