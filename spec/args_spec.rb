require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Cherrybase::Args do
  
  before(:each) do
    @args = Cherrybase::Args.new
  end
  
  it "should show help" do
    @args.parse(['--help']).should == {'help' => true}
  end
  
  it "should break up a range of commits and set the starting and the last commit" do
    @args.parse(['branch', 'start..end']).should == {'branch'=>'branch', 'starting-commit' => 'start', 'ending-commit' => 'end'}
  end
  
  it "should raise an error if a branch name is given without a commit hash" do
    lambda {
      @args.parse(['branch-name'])
    }.should raise_error(RuntimeError, 'You must supply at least the branch name and the starting commit hash to begin cherrybasing')
  end
  
  it "should set the branch name and the commit hash given" do
    @args.parse(['branch-name', 'commit-hash']).should == {'branch' => 'branch-name', 'starting-commit' => 'commit-hash'}
  end
  
  it "should raise an error if a commit hash is not given" do
    lambda {
      @args.parse([])
    }.should raise_error(RuntimeError, 'You must supply at least the branch name and the starting commit hash to begin cherrybasing')
  end
  
  it "should raise an error if both --abort and --continue are given" do
    lambda {
      @args.parse(['--abort', '--continue'])
    }.should raise_error(RuntimeError, "You supplied --abort and --continue, please pick one")
  end
  
  it "should set abort to true if --abort is given" do
    @args.parse(['--abort']).should == {'abort' => true, 'continue' => false}
  end
  
  it "should set continue to true if --continue is given" do
    @args.parse(['--continue']).should == {'continue' => true, 'abort' => false}
  end
  
end