desc 'Run unit tests'
task :test do
  sh 'ruby mml2smf.rb test/test.mml test/test.mid -v > test/test.actual.log'
  sh 'diff test/test.expected.log test/test.actual.log'
  sh 'ruby mml2smf.rb test/test-2.mml test/test-2.mid -v > test/test-2.actual.log'
  sh 'diff test/test-2.expected.log test/test-2.actual.log'
end
task :default => :test
