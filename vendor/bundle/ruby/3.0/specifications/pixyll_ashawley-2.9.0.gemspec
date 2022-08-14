# -*- encoding: utf-8 -*-
# stub: pixyll_ashawley 2.9.0 ruby lib

Gem::Specification.new do |s|
  s.name = "pixyll_ashawley".freeze
  s.version = "2.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "plugin_type" => "theme" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["John Otander".freeze]
  s.date = "2017-09-22"
  s.email = ["johnotander@gmail.com".freeze]
  s.homepage = "http://pixyll.com".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.17".freeze
  s.summary = "A simple, beautiful Jekyll theme that's mobile first.".freeze

  s.installed_by_version = "3.3.17" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<jekyll>.freeze, ["~> 3.3"])
    s.add_runtime_dependency(%q<jekyll-paginate>.freeze, ["~> 1.1"])
    s.add_development_dependency(%q<bundler>.freeze, ["~> 1.12"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
  else
    s.add_dependency(%q<jekyll>.freeze, ["~> 3.3"])
    s.add_dependency(%q<jekyll-paginate>.freeze, ["~> 1.1"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.12"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
  end
end
