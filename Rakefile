require 'rubygems'

begin
    require 'bundler'
    require 'bundler/setup'
rescue LoadError
    puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

task :default => :test

Bundler::GemHelper.install_tasks
