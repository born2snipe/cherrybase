require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Cherrybase::Baser do
  BRANCH = 'branch-name'
  
  before(:each) do
    @git = mock("git")
    @file_util = mock("file_util")
    @baser = Cherrybase::Baser.new(@git, @file_util)
  end
  
  it "should create the cherrybase temp file with the given branch's last commit" do
    @file_util.should_receive(:git_repo?).and_return(true)
    @file_util.should_receive(:temp_file?).and_return(false)
    @git.should_receive(:has_branch?).with(BRANCH).and_return(true)
    @git.should_receive(:last_commit).with(BRANCH).and_return('last-commit')
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