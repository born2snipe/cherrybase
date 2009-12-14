require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Cherrybase::FileUtil do
  
  before(:each) do
    @fixtures_dir = File.expand_path(File.join(File.join(__FILE__, ".."), ".."), "fixtures")
    @project = File.join(File.join(@fixtures_dir, "project"))
    @git_dir_name = 'git_dir'
    @file_util = Cherrybase::FileUtil.new(@git_dir_name)
  end
  
  it "should delete the temp file" do
    test_project = File.join(@fixtures_dir, 'cherrybase-inprogress')
    @file_util.write_temp_file("starting-commit", "next-commit", ["commit1", "commit2"], test_project)
    
    @file_util.delete_temp_file(test_project)
    @file_util.temp_file?(test_project).should == false
  end
  
  it "should read the temp file" do
    test_project = File.join(@fixtures_dir, 'cherrybase-inprogress')
    @file_util.write_temp_file("starting-commit", "next-commit", ["commit1", "commit2"], test_project)
    @file_util.read_temp_file(test_project).should == {
      "starting_commit" => "starting-commit",
      "next_cherrypick" => "next-commit",
      "commits" => ["commit1", "commit2"]
    }
  end
  
  it "should return nil if the temp file does not exist in the .git folder" do
    expected_tempfile = File.join(File.join(@project, @git_dir_name), 'cherrybase')
    @file_util.temp_file?(@project).should == false
  end
  
  it "should find the temp file if it exists in the .git folder" do
    test_project = File.join(@fixtures_dir, 'cherrybase-inprogress')
    @file_util.write_temp_file("starting-commit", "next-commit", ["commit1", "commit2"], test_project)
    expected_tempfile = File.join(File.join(test_project, @git_dir_name), 'cherrybase')
    @file_util.temp_file?(test_project).should == true
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