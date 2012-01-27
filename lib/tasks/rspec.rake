require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = './spec/**/*_spec.rb' #Dir['spec/**/*_spec.rb']
  #t.spec_opts  = %w(-fs --color)
end

task :default => :spec
