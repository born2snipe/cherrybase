require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Cherrybase::Baser do
  
  before(:each) do
    @git = mock("git")
    @file_util = mock("file_util")
    @baser = Cherrybase::Baser.new(@git, @file_util)
  end
  
  it "should throw an exception if the git repo folder could not be discovered" do
    lambda {
      @file_util.should_receive(:git_repo?).and_return(false)
      @baser.init()
    }.should raise_error(RuntimeError, "Could not locate .git folder! Is this a Git repository?")
  end
  
  it "should load the temp file if it exists already" do
    filename = File.expand_path('.')
    
    @file_util.should_receive(:git_repo?).and_return(true)
    @file_util.should_receive(:git_root_dir).and_return(filename)
    @file_util.should_receive(:temp_file).with(filename).and_return({
      "last_svn_commit" => "last_svn_commit",
      "commits_to_cherrypick" => ["commit1", "commit2"],
      "next_cherrypick" => "commit3"
    })
    
    @baser.init()
    
    @baser.last_svn_commit.should == "last_svn_commit"
    @baser.commits_to_cherrypick.should == ["commit1", "commit2"]
    @baser.next_cherrypick.should == "commit3"
  end
  
  it "should create the temp file with all the commits to be cherry picked and the last svn commit" do
    commits = ["commit1", "commit2"]
    filename = File.expand_path('.')
    
    @file_util.should_receive(:git_repo?).and_return(true)
    @file_util.should_receive(:git_root_dir).and_return(filename)
    @file_util.should_receive(:temp_file).with(filename).and_return(nil)
    @file_util.should_receive(:write_temp_file).with(filename, "last_svn_commit", "commit1", commits)
    
    @git.should_receive(:last_svn_commit).and_return("last_svn_commit")
    @git.should_receive(:commits_to_cherrypick).and_return(commits)
    
    @baser.init()
    
    @baser.last_svn_commit.should == "last_svn_commit"
    @baser.commits_to_cherrypick.should == ["commit1", "commit2"]
    @baser.next_cherrypick.should == "commit1"
  end
  
end