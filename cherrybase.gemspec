# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cherrybase}
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["born2snipe"]
  s.date = %q{2010-01-12}
  s.default_executable = %q{cherrybase}
  s.description = %q{Ruby gem to cherry-pick a range of commits with similar rebase options}
  s.email = %q{born2snipe@gmail.com}
  s.executables = ["cherrybase"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/cherrybase",
     "cherrybase.gemspec",
     "fixtures/cherrybase-inprogress/git_dir/cherrybase",
     "fixtures/project/git_dir/some_git_file",
     "fixtures/project/module/some_module_file",
     "lib/args.rb",
     "lib/baser.rb",
     "lib/cmd.rb",
     "lib/executor.rb",
     "lib/file_util.rb",
     "lib/git.rb",
     "lib/validator.rb",
     "spec/args_spec.rb",
     "spec/baser_spec.rb",
     "spec/executor_spec.rb",
     "spec/file_util_spec.rb",
     "spec/git_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "spec/validator_spec.rb"
  ]
  s.homepage = %q{http://github.com/born2snipe/cherrybase}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Ruby gem to cherry-pick a range of commits with similar rebase options}
  s.test_files = [
    "spec/args_spec.rb",
     "spec/baser_spec.rb",
     "spec/executor_spec.rb",
     "spec/file_util_spec.rb",
     "spec/git_spec.rb",
     "spec/spec_helper.rb",
     "spec/validator_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
  end
end

