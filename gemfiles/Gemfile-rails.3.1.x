filename = File.expand_path(File.dirname(__FILE__)+"/Gemfile.shared")
eval(IO.read(filename), binding)

gem 'taggable_cache', :path => '..'

gem 'rails', '~> 3.1.0'
gem 'redis-rails', '~>3.1.0'