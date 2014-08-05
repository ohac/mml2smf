desc 'Run unit tests'
task :test do
  sh 'ruby mml2smf.rb test/test.mml test/test.mid -v > test/test.actual.log'
  sh 'diff test/test.expected.log test/test.actual.log'
end
task :default => :test
