filename = File.expand_path(File.dirname(__FILE__)+"/gemfiles/Gemfile.shared")
eval(IO.read(filename), binding)

gemspec

group :development do
  gem 'pry'
  gem 'pry-nav'
end

gem 'rails', '~> 3.2.0'