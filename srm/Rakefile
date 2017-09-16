require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'unit_tests'
  t.test_files = FileList['unit_tests/test_*.rb']
end

desc "Run tests"
task :default => :test

