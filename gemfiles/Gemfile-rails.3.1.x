filename="Gemfile.shared"
eval(IO.read(filename), binding)

gem 'taggable_cache', :path => '..'

gem 'rails', '~> 3.1.0'