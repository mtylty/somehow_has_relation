# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "somehow_has_relation/version"

Gem::Specification.new do |s|
  s.name        = "somehow_has_relation"
  s.version     = SomehowHasRelation::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matteo Latini"]
  s.email       = ["mtylty@gmail.com", "m.latini@caspur.it"]
  s.homepage    = "https://github.com/mtylty/somehow_has_relation"
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{simple recursive activerecord relations for rails2 and rails3}

  s.rubyforge_project = "somehow_has_relation"

  s.files         = `git ls-files -x test`.split("\n")
  s.require_paths = ["lib"]
end
