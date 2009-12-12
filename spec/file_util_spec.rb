require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Cherrybase::FileUtil do
  
  before(:each) do
    @fixtures_dir = File.expand_path(File.join(File.join(__FILE__, ".."), ".."), "fixtures")
    @project = File.join(File.join(@fixtures_dir, "project"))
    @file_util = Cherrybase::FileUtil.new
  end
  
  it "should return nil if the temp file does not exist in the .git folder" do
    expected_tempfile = File.join(File.join(@project, '.git'), 'cherrybase')
    @file_util.temp_file(@project).should == expected_tempfile
  end
  
  it "should find the temp file if it exists in the .git folder" do
    test_project = File.join(@fixtures_dir, 'cherrybase-inprogress')
    expected_tempfile = File.join(File.join(test_project, '.git'), 'cherrybase')
    @file_util.temp_file(test_project).should == expected_tempfile
  end

  it "should recursively look up the directory tree and return the project directory" do
    @file_util.git_root_dir(File.join(@project, "module")).should == @project
  end
  
  it "should return the current directory if the current directory contains the .git folder" do
    @file_util.git_root_dir(@project).should == @project
  end

  it "should recursively look up directory tree for a git repository" do
    @file_util.git_repo?(File.join(@project, "module")).should == true
  end

  it "should find git repo if in the git main dir" do
    @file_util.git_repo?(@project).should == true
  end

end