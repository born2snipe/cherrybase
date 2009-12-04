require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Cherrybase::Git do
  
  before(:each) do
    @cmd = mock("cmd")
    @git = Cherrybase::Git.new(@cmd)
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
