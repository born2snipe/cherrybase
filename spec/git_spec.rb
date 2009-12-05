require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Cherrybase::Git do
  
  before(:each) do
    @cmd = mock("cmd")
    @git = Cherrybase::Git.new(@cmd)
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
  
  it "should grab all commit hashes after the last svn commit" do
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
    
    pretty_log_lines = ["hash1 comment-1", "hash2 comment-2"]
    
    @cmd.should_receive(:run).with("git log").and_return(log_lines)
    @cmd.should_receive(:run).with("git log --pretty=oneline").and_return(pretty_log_lines)
    
    @git.commits_to_cherrypick().should == ["hash1"]
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
