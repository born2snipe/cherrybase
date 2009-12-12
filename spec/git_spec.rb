require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Cherrybase::Git do
  
  before(:each) do
    @cmd = mock("cmd")
    @git = Cherrybase::Git.new(@cmd)
  end
  
  it "should reset the HEAD to the given commit" do
    @cmd.should_receive(:run).with("git reset --hard commit")
    
    @git.reset("commit")
  end
  
  it "should raise an error if the commit hash given is not at least 5 characters" do
    lambda {
      @git.has_commit?("branch", "1234")
    }.should raise_error(RuntimeError, "Please supply at least 5 characters for a commit hash")
  end
  
  it "should return true if a partial match is found for the given hash" do
    @cmd.should_receive(:run).with("git log branch --pretty=oneline").and_return(["commit1", "commit2-hash", "commit3"])
    @git.has_commit?("branch", "-hash").should == true
  end
  
  it "should return true if an exact match is found for the given hash" do
    @cmd.should_receive(:run).with("git log branch --pretty=oneline").and_return(["commit"])
    @git.has_commit?("branch", "commit").should == true
  end
  
  it "should return false if a hash could not be found in the history of the given branch" do
    @cmd.should_receive(:run).with("git log branch --pretty=oneline").and_return([])
    @git.has_commit?("branch", "commit").should == false
  end
  
  it "should return nil if there is no commit history" do
    @cmd.should_receive(:run).with("git log branch --pretty=oneline").and_return([])
    @git.last_commit('branch').should == nil
  end
  
  it "should return the last commit of the given branch" do
    pretty_log_lines = ["hash1 comment-1", "hash2 comment-2", "hash3 comment-3"]
    @cmd.should_receive(:run).with("git log branch --pretty=oneline").and_return(pretty_log_lines)
    @git.last_commit('branch').should == 'hash1'
  end
  
  it "should return the current branch name" do
    @cmd.should_receive(:run).with("git branch").and_return(["branch1", "* branch2"])
    @git.current_branch().should == "branch2"
  end
  
  it "should return false if the branch does not exist" do
    @cmd.should_receive(:run).with("git branch").and_return(["branch1", "branch2"])
    @git.has_branch?("doesNotExist").should == false
  end
  
  it "should return true if the branch exists" do
    @cmd.should_receive(:run).with("git branch").and_return([" branch1", " branch2"])
    @git.has_branch?("branch2").should == true
  end
  
  it "should cherry-pick the given commit hash" do
    commit_hash = "commit hash"
    @cmd.should_receive(:run).with("git cherry-pick #{commit_hash}")
    @git.cherry_pick(commit_hash)
  end
  
  it "should return false if no files are marked as unmerged" do
    @cmd.should_receive(:run).with("git ls-files -tu").and_return([])
    
    @git.has_conflicts?().should == false
  end
  
  it "should return true if files are marked as unmerged" do
    log_lines = [
      "M 100644 e01079f2c38b76cf43780a2899c3f5bd2f50b3a7 1	readme.txt",
      "M 100644 f7b5ff223f06fb323463b81b08759cf13678fd27 2	readme.txt",
      "M 100644 0ebe257230ddb66e12610ad9b304c7605b61dfeb 3	readme.txt"
    ]
    
    @cmd.should_receive(:run).with("git ls-files -tu").and_return(log_lines)
    
    @git.has_conflicts?().should == true
  end
  
  it "should shell out a commit" do
    commit_hash = "commit hash"
    
    @cmd.should_receive(:run).with("git commit -C #{commit_hash}")
    
    @git.commit(commit_hash)
  end
  
  it "should shell out a git status" do
    @cmd.should_receive(:run).with("git status", true)
    
    @git.status
  end
  
  it "should grab all commit hashes after the commit and the last commit given" do
    pretty_log_lines = ["hash1 comment-1", "hash2 comment-2", "hash3 comment-3", "hash4 commit-4"]
    
    @cmd.stub!(:run).with("git log branch --pretty=oneline").and_return(pretty_log_lines)
    
    @git.commits_to_cherrypick("branch", "hash3", "hash2").should == ["hash3", "hash2"]
  end
  
  it "should grab all commit hashes after the commit and the commit given" do
    pretty_log_lines = ["hash1 comment-1", "hash2 comment-2", "hash3 comment-3"]
    
    @cmd.stub!(:run).with("git log branch --pretty=oneline").and_return(pretty_log_lines)
    
    @git.commits_to_cherrypick("branch", "hash2").should == ["hash2", "hash1"]
  end

  
  it "should return nil if no svn commit was found" do
    log_lines = [
      "commit hash1",
      "Author: author-1",
      "Date: date-1",
      "",
      " comment-1",
      ""
    ]
    
    @cmd.stub!(:run).and_return(log_lines)
    
    @git.last_svn_commit.should == nil
  end
  
  it "should find the last svn commit hash" do
    log_lines = [
      "commit hash1",
      "Author: author-1",
      "Date: date-1",
      "",
      " comment-1",
      "",
      "commit hash2",
      "Author: author-2",
      "Date: date-2",
      "",
      "comment-2",
      "",
      " git-svn-id: url",
      ""
    ]
    
    @cmd.stub!(:run).and_return(log_lines)
    
    @git.last_svn_commit.should == "hash2"
  end
  
end
