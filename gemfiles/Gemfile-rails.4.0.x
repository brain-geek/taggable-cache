filename = File.expand_path(File.dirname(__FILE__)+"/Gemfile.shared")
eval(IO.read(filename), binding)

gem 'taggable_cache', :path => '..'

gem 'rails', '~>4.0.2'
gem 'redis-rails', '~>4.0.0'