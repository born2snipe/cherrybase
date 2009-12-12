module Cherrybase
  class FileUtil
    def git_repo?(directory = File.expand_path('.'))
      git_root_dir(directory) != nil
    end
    
    def git_root_dir(directory = File.expand_path('.'))
      current_directory = directory  
      while !File.exists?(File.join(current_directory, '.git'))
        current_directory = File.dirname(current_directory)
      end
      current_directory
    end
    
    def temp_file?(directory = File.expand_path('.'))
    end
    
    def temp_file(directory = File.expand_path('.'))
      File.join(File.join(git_root_dir(directory), '.git'), 'cherrybase')
    end
    
    def write_temp_file(starting_commit, next_cherrypick, commits)
    end
  end
end