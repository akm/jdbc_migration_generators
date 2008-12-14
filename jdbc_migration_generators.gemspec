require 'rake'

Gem::Specification.new do |spec|
  spec.name = "jdbc_migration_generators"
  spec.version = "0.0.1"
  spec.platform = "java"
  spec.summary = "jdbc_migration_generators helps your migration from an legacy database schema to rails style database schama"
  spec.author = "Takeshi Akima"
  spec.email = "rubeus@googlegroups.com"
  spec.homepage = "http://code.google.com/p/rubeus/"
  spec.rubyforge_project = "rubybizcommons"
  spec.has_rdoc = false

  spec.add_dependency("rubeus", ">= 0.0.8")
  spec.files = FileList['Rakefile', 'bin/*', '*.rb', '{lib,test}/**/*.{rb}', 'generators/**/*.{rb}'].to_a
  spec.require_path = "lib"
  spec.requirements = ["none"]
  # spec.autorequire = 'jdbc_migration_generator' # autorequire is deprecated
  
  bin_files = FileList['bin/*'].to_a.map{|file| file.gsub(/^bin\//, '')}
  spec.executables = bin_files
  
  puts bin_files

  # spec.default_executable = 'some_executable.sh'
end
