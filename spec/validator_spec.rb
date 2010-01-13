require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Cherrybase::Validator do
  BRANCH = "branch-name"

  before(:each) do
    @git = mock("git")
    @file_util = mock("file_util")
    @validator = Cherrybase::Validator.new(@git, @file_util)
  end

  it "should not raise any errors" do
    @file_util.should_receive(:git_repo?).and_return(true)
    @git.should_receive(:has_branch?).with(BRANCH).and_return(true)
    @file_util.should_receive(:temp_file?).and_return(false)
    @git.should_receive(:has_commit?).with(BRANCH, "start-commit").and_return(true)
    @git.should_receive(:has_commit?).with(BRANCH, "end-commit").and_return(true)

    @validator.validate_init(BRANCH, "start-commit", "end-commit", nil)
  end

  it "should raise an error if the last SVN commit could not be found" do
    @file_util.should_receive(:git_repo?).and_return(true)
    @git.should_receive(:has_branch?).with(BRANCH).and_return(true)
    @file_util.should_receive(:temp_file?).and_return(false)
    @git.should_receive(:last_svn_commit).with(BRANCH).and_return(nil)

    lambda {
      @validator.validate_init(BRANCH, nil, nil, true)
    }.should raise_error(RuntimeError, "Could not locate the last SVN commit in branch (#{BRANCH})")
  end

  it "should raise an error if the given ending commit can not be found for the given branch" do
    @file_util.should_receive(:git_repo?).and_return(true)
    @git.should_receive(:has_branch?).with(BRANCH).and_return(true)
    @file_util.should_receive(:temp_file?).and_return(false)
    @git.should_receive(:has_commit?).with(BRANCH, "start-commit").and_return(true)
    @git.should_receive(:has_commit?).with(BRANCH, "end-commit").and_return(false)

    lambda {
      @validator.validate_init(BRANCH, "start-commit", "end-commit", nil)
    }.should raise_error(RuntimeError, "Could not locate END hash (end-commit) in the Git repository history")
  end


  it "should not check for start commit hash if using the last SVN commit" do
    @file_util.should_receive(:git_repo?).and_return(true)
    @git.should_receive(:has_branch?).with(BRANCH).and_return(true)
    @file_util.should_receive(:temp_file?).and_return(false)
    @git.should_receive(:last_svn_commit).with(BRANCH).and_return("last-svn-commit")

    @validator.validate_init(BRANCH, nil, nil, true)
  end

  it "should raise an error if the given starting commit can not be found for the given branch" do
    @file_util.should_receive(:git_repo?).and_return(true)
    @git.should_receive(:has_branch?).with(BRANCH).and_return(true)
    @file_util.should_receive(:temp_file?).and_return(false)
    @git.should_receive(:has_commit?).with(BRANCH, "start-commit").and_return(false)

    lambda {
      @validator.validate_init(BRANCH, "start-commit", nil, nil)
    }.should raise_error(RuntimeError, "Could not locate START hash (start-commit) in the Git repository history")
  end

  it "should raise an error if you are currently in the middle of a cherrybase already" do
    @file_util.should_receive(:git_repo?).and_return(true)
    @git.should_receive(:has_branch?).with(BRANCH).and_return(true)
    @file_util.should_receive(:temp_file?).and_return(true)

    lambda {
      @validator.validate_init(BRANCH, nil, nil, nil)
    }.should raise_error(RuntimeError, "It appears you are already in the middle of a cherrybase!?")
  end

  it "should raise an error if the branch given is NOT found in the repository" do
    @file_util.should_receive(:git_repo?).and_return(true)
    @git.should_receive(:has_branch?).with(BRANCH).and_return(false)

    lambda {
      @validator.validate_init(BRANCH, nil, nil, nil)
    }.should raise_error(RuntimeError, "Could not find branch (#{BRANCH}) in the Git repository")
  end

  it "should raise an error if the current directory is NOT a git repository" do
    @file_util.should_receive(:git_repo?).and_return(false)

    lambda {
      @validator.validate_init(nil, nil, nil, nil)
    }.should raise_error(RuntimeError, "Could not locate .git folder! Is this a Git repository?")
  end

end