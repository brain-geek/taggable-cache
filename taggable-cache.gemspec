# -*- encoding: utf-8 -*-

require 'rake'
$:.push File.expand_path("../lib", __FILE__)
require "taggable_cache/version"

Gem::Specification.new do |s|
  s.name = "taggable_cache"
  s.version = TaggableCache::VERSION

  s.authors = ["Alex Rozumey"]
  s.date = "2012-02-09"
  s.description = "This gem simplifies cache expiration in rails"
  s.email = "brain-geek@yandex.ua"

  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.homepage = "http://github.com/brain-geek/taggable-cache"
  s.licenses = ["MIT"]
  s.rubygems_version = "1.8.15"
  s.summary = "This gem simplifies cache expiration in rails by providing depends_on option to rails cache."

  #s.add_dependency(%q<rails>, [">= 3.1.0"])
  s.add_dependency(%q<railties>, [">= 3.1.0"])
  s.add_dependency(%q<actionpack>, [">= 3.1.0"])
  s.add_dependency(%q<activerecord>, [">= 3.1.0"])
  s.add_dependency(%q<redis>, [">= 2.2.2"])
end

