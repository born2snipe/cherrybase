require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Cherrybase::Baser do
  BRANCH = 'branch-name'
  
  before(:each) do
    @git = mock("git")
    @file_util = mock("file_util")
    @baser = Cherrybase::Baser.new(@git, @file_util)
  end
  
  it "should raise an error if the end commit could not be located in the history" do
    @file_util.should_receive(:git_repo?).and_return(true)
    @file_util.should_receive(:temp_file?).and_return(false)
    @git.should_receive(:has_branch?).with(BRANCH).and_return(true)
    @git.should_receive(:has_commit?).with(BRANCH, "start").and_return(true)
    @git.should_receive(:has_commit?).with(BRANCH, "end").and_return(false)
    lambda {
      @baser.init(BRANCH, "start", "end")
    }.should raise_error(RuntimeError, "Could not locate END hash (end) in the Git repository history")
  end
  
  it "should raise an error if the start commit could not be located in the history" do
    @file_util.should_receive(:git_repo?).and_return(true)
    @file_util.should_receive(:temp_file?).and_return(false)
    @git.should_receive(:has_branch?).with(BRANCH).and_return(true)
    lambda {
      @git.should_receive(:has_commit?).with(BRANCH, "doesNotExist").and_return(false)
      @baser.init(BRANCH, "doesNotExist", nil)
    }.should raise_error(RuntimeError, "Could not locate START hash (doesNotExist) in the Git repository history")
  end
  
  it "should commit staged merge resolution" do
    @file_util.should_receive(:temp_file?).and_return(true)
    @file_util.should_receive(:read_temp_file).and_return({
      "starting_commit" => "start",
      "next_cherrypick" => "commit1",
      "commits" => ["start", "commit1"]
    })
    @git.should_receive(:commit).with("start")
    @git.should_receive(:cherry_pick).with("commit1")
    @git.should_receive(:has_conflicts?).and_return(false)
    @file_util.should_receive(:delete_temp_file)
    
    @baser.continue(true)
  end
  
  it "should start apply commits based on the next_cherrypick" do
    @file_util.should_receive(:temp_file?).and_return(true)
    @file_util.should_receive(:read_temp_file).and_return({
      "starting_commit" => "start",
      "next_cherrypick" => "commit1",
      "commits" => ["start", "commit1"]
    })
    @git.should_receive(:cherry_pick).with("commit1")
    @git.should_receive(:has_conflicts?).and_return(false)
    @file_util.should_receive(:delete_temp_file)
    
    @baser.continue
  end
  
  it "should cleanup the temp file if a conflict is encountered on the last commit" do
    @file_util.should_receive(:temp_file?).and_return(true)
    @file_util.should_receive(:read_temp_file).and_return({
      "starting_commit" => "start",
      "next_cherrypick" => "start",
      "commits" => ["start"]
    })
    @git.should_receive(:cherry_pick).with("start")
    @git.should_receive(:has_conflicts?).and_return(true)
    @git.should_receive(:status)
    @file_util.should_receive(:delete_temp_file)
    
    @baser.continue
  end
  
  it "should stop cherrypicking if a conflict is found" do
    @file_util.should_receive(:temp_file?).and_return(true)
    @file_util.should_receive(:read_temp_file).and_return({
      "starting_commit" => "start",
      "next_cherrypick" => "start",
      "commits" => ["start", "end"]
    })
    @git.should_receive(:cherry_pick).with("start")
    @git.should_receive(:has_conflicts?).and_return(true)
    @git.should_receive(:status)
    @file_util.should_receive(:write_temp_file).with("start", "end", ["start", "end"])
    
    @baser.continue
  end
  

  it "should attempt to cherry-pick all the commits left (two commits)" do
    @file_util.should_receive(:temp_file?).and_return(true)
    @file_util.should_receive(:read_temp_file).and_return({
      "starting_commit" => "start",
      "next_cherrypick" => "start",
      "commits" => ["start", "end"]
    })
    @git.should_receive(:cherry_pick).with("start")
    @git.should_receive(:cherry_pick).with("end")
    @git.should_receive(:has_conflicts?).and_return(false)
    @git.should_receive(:has_conflicts?).and_return(false)
    @file_util.should_receive(:delete_temp_file)
    
    @baser.continue
  end
  
  it "should attempt to cherry-pick all the commits left (one commit)" do
    @file_util.should_receive(:temp_file?).and_return(true)
    @file_util.should_receive(:read_temp_file).and_return({
      "starting_commit" => "start",
      "next_cherrypick" => "start",
      "commits" => ["start"]
    })
    @git.should_receive(:cherry_pick).with("start")
    @git.should_receive(:has_conflicts?).and_return(false)
    @file_util.should_receive(:delete_temp_file)
    
    @baser.continue
  end
  
  it "should throw an error if you are not in the middle of a cherrybase" do
    @file_util.should_receive(:temp_file?).and_return(false)
    lambda {
      @baser.continue
    }.should raise_error(RuntimeError, "It appears you are not in the middle of a cherrybase!?")
  end
  
  it "should create the cherrybase temp file with the given branch's last commit" do
    @file_util.should_receive(:git_repo?).and_return(true)
    @file_util.should_receive(:temp_file?).and_return(false)
    @git.should_receive(:has_branch?).with(BRANCH).and_return(true)
    @git.should_receive(:last_commit).with(BRANCH).and_return('last-commit')
    @git.should_receive(:has_commit?).with(BRANCH, 'starting-commit').and_return(true)
    @git.should_receive(:commits_to_cherrypick).with('starting-commit', 'last-commit').and_return(['commits-to-cherrypick'])
    @file_util.should_receive(:write_temp_file).with('starting-commit', 'starting-commit', ['commits-to-cherrypick'])
    @baser.init(BRANCH, 'starting-commit', nil)
  end
  
  it "should throw an error if the given branch name does not exist in the repository" do
    lambda {
      @file_util.should_receive(:git_repo?).and_return(true)
      @git.should_receive(:has_branch?).with(BRANCH).and_return(false)
      @baser.init(BRANCH, nil, nil)
    }.should raise_error(RuntimeError, "Could not find branch (branch-name) in the Git repository")
  end
  
  it "should throw an exception if the git repo folder could not be discovered" do
    lambda {
      @file_util.should_receive(:git_repo?).and_return(false)
      @baser.init(nil, nil, nil)
    }.should raise_error(RuntimeError, "Could not locate .git folder! Is this a Git repository?")
  end
  
  it "should throw an error if you already in the middle of a cherrybase" do
    @file_util.should_receive(:git_repo?).and_return(true)
    @git.should_receive(:has_branch?).with(BRANCH).and_return(true)
    lambda {
      @file_util.should_receive(:temp_file?).and_return(true)
      @baser.init("branch-name", nil, nil)
    }.should raise_error(RuntimeError, "It appears you are already in the middle of a cherrybase!?")
  end
  
end