filename = File.expand_path(File.dirname(__FILE__)+"/gemfiles/Gemfile.shared")
eval(IO.read(filename), binding)

gemspec

gem 'rails', '~> 3.2.0'
gem 'redis-rails', '~>3.2.3'

group :development do
  gem 'pry'
  gem 'pry-nav'
end