# -*- encoding: utf-8 -*-
# stub: rb-kqueue 0.2.8 ruby lib

Gem::Specification.new do |s|
  s.name = "rb-kqueue".freeze
  s.version = "0.2.8".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mathieu Arnold".freeze, "Nathan Weizenbaum".freeze]
  s.date = "2022-02-07"
  s.description = "A Ruby wrapper for BSD's kqueue, using FFI".freeze
  s.email = "mat@mat.cc nex342@gmail.com".freeze
  s.extra_rdoc_files = ["README.md".freeze]
  s.files = ["README.md".freeze]
  s.homepage = "http://github.com/mat813/rb-kqueue".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--charset=UTF-8".freeze]
  s.rubygems_version = "3.5.9".freeze
  s.summary = "A Ruby wrapper for BSD's kqueue, using FFI".freeze

  s.installed_by_version = "3.5.9".freeze if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<ffi>.freeze, [">= 0.5.0".freeze])
  s.add_development_dependency(%q<yard>.freeze, [">= 0.4.0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, [">= 3.3.0".freeze])
end
