$: << File.join(File.dirname(__FILE__), 'lib')

desc 'Run unit tests'
task :test do
  ['test', 'test-2', 'test-code', 'test-code2'].each do |name|
    mml = "test/#{name}.mml"
    mid = "test/#{name}.mid"
    actual = "test/#{name}.actual.log"
    expected = "test/#{name}.expected.log"
    sh "ruby bin/mml2smf #{mml} #{mid} -v > #{actual}"
    if File.exist?(expected)
      sh "diff #{expected} #{actual}"
    end
  end
end
task :default => :test
