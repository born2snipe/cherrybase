require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Cherrybase::Executor do
  
  before(:each) do
    @baser = mock('baser')
    @executor = Cherrybase::Executor.new(@baser)
  end
  
  it "should tell the baser to init with the appropriate branch name and range of commits" do
    @baser.should_receive(:init).with('branch-name', 'starting-commit', 'ending-commit')
    @baser.should_receive(:continue)
    @executor.execute(['branch-name', 'starting-commit..ending-commit'])    
  end
  
  it "should tell the baser to init with the appropriate branch and starting commit" do
    @baser.should_receive(:init).with('branch-name', 'starting-commit', nil)
    @baser.should_receive(:continue)
    @executor.execute(['branch-name', 'starting-commit'])
  end

  it "should tell the baser to abort" do
    @baser.should_receive(:abort)
    @executor.execute(['--abort'])
  end

  it "should tell the baser to continue to the next commit" do
    @baser.should_receive(:continue)
    @executor.execute(['--continue'])
  end
  
end