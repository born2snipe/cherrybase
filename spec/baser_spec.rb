require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Cherrybase::Baser do
  BRANCH = 'branch-name'
  
  before(:each) do
    @git = mock("git")
    @file_util = mock("file_util")
    @validator = mock("validator")
    @baser = Cherrybase::Baser.new(@git, @file_util, @validator)
    
    @first_commit = "commit1"
    @commits = ["commit1", "commit2"]
  end
  
  it "should not care about case of the SVN given" do
    @validator.should_receive(:validate_init)
    @git.should_receive(:last_svn_commit).with(BRANCH).and_return('svn_commit')
    @git.should_receive(:last_commit).with(BRANCH).and_return('last_commit')
    @git.should_receive(:commits_to_cherrypick).with(BRANCH, 'svn_commit', 'last_commit').and_return(['svn', 'commit1', 'commit2'])
    @git.stub!(:current_branch).and_return("current")
    @git.stub!(:last_commit).with("current").and_return("last_original_commit")
    @file_util.should_receive(:write_temp_file).with('last_original_commit', @first_commit, @commits)
    
    @baser.init(BRANCH, "SvN", nil)
  end
  
  it "should find the commit after the last svn commit and use it as the starting commit" do
    @validator.should_receive(:validate_init)
    @git.should_receive(:last_svn_commit).with(BRANCH).and_return('svn_commit')
    @git.should_receive(:last_commit).with(BRANCH).and_return('last_commit')
    @git.should_receive(:commits_to_cherrypick).with(BRANCH, 'svn_commit', 'last_commit').and_return(['svn', 'commit1', 'commit2'])
    @git.stub!(:current_branch).and_return("current")
    @git.stub!(:last_commit).with("current").and_return("last_original_commit")
    @file_util.should_receive(:write_temp_file).with('last_original_commit', @first_commit, @commits)
    
    @baser.init(BRANCH, "svn", nil)
  end
  
  it "should raise an error if your try to continue with changes that are unstaged" do
    @file_util.should_receive(:temp_file?).and_return(true)
    @file_util.should_receive(:read_temp_file).and_return({})
    @git.stub!(:has_conflicts?).and_return(true)
    
    lambda {
      @baser.continue(true)
    }.should raise_error(RuntimeError, "Please stage all your changes before trying to --continue")
  end
  
  it "should reset HEAD back to the last original commit before any cherry-picks" do
    @file_util.stub!(:temp_file?).and_return(true)
    @file_util.stub!(:read_temp_file).and_return({"starting_commit" => "start"})
    @file_util.should_receive(:delete_temp_file)
    @git.should_receive(:reset).with("start")
    
    @baser.abort
  end
  
  it "should raise an error if you try to abort while not in a cherrybase" do
    @file_util.should_receive(:temp_file?).and_return(false)
    
    lambda {
      @baser.abort
    }.should raise_error(RuntimeError, "It appears you are not in the middle of a cherrybase!?")
  end
  
  it "should use the end commit if given" do
    @validator.should_receive(:validate_init)
    @git.should_receive(:commits_to_cherrypick).with(BRANCH, @first_commit, 'last_commit').and_return(@commits)
    @git.stub!(:resolve_commit).with(BRANCH, "starting-commit").and_return(@first_commit)
    @git.stub!(:resolve_commit).with(BRANCH, "end-commit").and_return("last_commit")
    @file_util.should_receive(:write_temp_file).with('last_original_commit', @first_commit, @commits)
    @git.stub!(:current_branch).and_return("current")
    @git.stub!(:last_commit).with("current").and_return("last_original_commit")
    
    @baser.init(BRANCH, 'starting-commit', "end-commit")
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
    @git.stub!(:has_conflicts?).and_return(false)
    
    @baser.continue(true)
  end
  
  it "should handle if the last commit had a conflict and you continue with committing" do
    @file_util.should_receive(:temp_file?).and_return(true)
    @file_util.should_receive(:read_temp_file).and_return({
      "starting_commit" => "start",
      "next_cherrypick" => nil,
      "commits" => ["start", "commit1"]
    })
    @git.should_receive(:has_conflicts?).and_return(false)
    @git.should_receive(:commit).with("commit1")
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
  
  it "should stop cherrypicking if a conflict is found, with multiple commits left" do
    @file_util.should_receive(:temp_file?).and_return(true)
    @file_util.should_receive(:read_temp_file).and_return({
      "starting_commit" => "start",
      "next_cherrypick" => "start",
      "commits" => ["start", "middle", "end"]
    })
    @git.should_receive(:cherry_pick).with("start")
    @git.should_receive(:has_conflicts?).and_return(true)
    @git.should_receive(:status)
    @file_util.should_receive(:write_temp_file).with("start", "middle", ["start", "middle", "end"])
    
    @baser.continue
  end
  
  
  it "should stop cherrypicking if a conflict is found, only one commit left" do
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
    @validator.should_receive(:validate_init)
    @git.should_receive(:last_commit).with(BRANCH).and_return('last-commit')
    @git.should_receive(:commits_to_cherrypick).with(BRANCH, @first_commit, 'last-commit').and_return(@commits)
    @git.stub!(:resolve_commit).with(BRANCH, "starting-commit").and_return(@first_commit)
    @git.stub!(:current_branch).and_return("current")
    @git.stub!(:last_commit).with("current").and_return("last_original_commit")
    @file_util.should_receive(:write_temp_file).with('last_original_commit', @first_commit, @commits)
    @baser.init(BRANCH, 'starting-commit', nil)
  end
  
end