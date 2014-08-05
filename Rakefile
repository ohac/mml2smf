desc 'Run unit tests'
task :test do
  ['test', 'test-2', 'test-code'].each do |name|
    mml = "test/#{name}.mml"
    mid = "test/#{name}.mid"
    actual = "test/#{name}.actual.log"
    expected = "test/#{name}.expected.log"
    sh "ruby mml2smf.rb #{mml} #{mid} -v > #{actual}"
    if File.exist?(expected)
      sh "diff #{expected} #{actual}"
    end
  end
end
task :default => :test
