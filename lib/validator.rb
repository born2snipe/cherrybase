module Cherrybase
  class Validator

    def initialize(git = Cherrybase::Git.new, file_util = Cherrybase::FileUtil.new)
      @git = git
      @file_util = file_util
    end

    def validate_init(branch_name, starting_commit, ending_commit, use_svn_commit)
      raise "Could not locate .git folder! Is this a Git repository?" if !@file_util.git_repo?
      raise "Could not find branch (#{branch_name}) in the Git repository" if !@git.has_branch?(branch_name)
      raise "It appears you are already in the middle of a cherrybase!?" if @file_util.temp_file?
      raise "Could not locate START hash (#{starting_commit}) in the Git repository history" if !use_svn_commit && !@git.has_commit?(branch_name, starting_commit)
      raise "Could not locate END hash (#{ending_commit}) in the Git repository history" if ending_commit != nil && !@git.has_commit?(branch_name, ending_commit)
    end

  end
end
