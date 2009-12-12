require 'yaml'

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
      File.exist?(temp_file(directory))
    end
    
    def temp_file(directory = File.expand_path('.'))
      File.join(File.join(git_root_dir(directory), '.git'), 'cherrybase')
    end
    
    def delete_temp_file(directory = File.expand_path('.'))
      File.delete(temp_file(directory))
    end
    
    def read_temp_file(directory = File.expand_path('.'))
      YAML::load_file( temp_file(directory) )
    end
    
    def write_temp_file(starting_commit = nil, next_cherrypick = nil, commits = nil, directory = File.expand_path('.'))
      data = {
        "starting_commit" => starting_commit,
        "next_cherrypick" => next_cherrypick,
        "commits" => commits
      }
      filename = temp_file(directory)
      File.open(filename, "w") do |f|
          f.write(YAML::dump(data))
      end
    end
  end
end