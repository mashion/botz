$:.unshift File.expand_path("../lib", __FILE__)

require 'botz/version'

spec = Gem::Specification.new do |s|
  s.name = "botz"
  s.version = Botz::VERSION
  s.author = "Mashion"
  s.email = "trotter@mashion.net"
  s.homepage = "http://mashion.net"
  s.description = s.summary = "Event Machine based IRC Bot"

  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.md", "LICENSE"]

  s.add_dependency "eventmachine", "1.0.0.beta.3"

  s.add_development_dependency "rake"

  s.require_path = 'lib'
  s.files = %w(LICENSE README.md Rakefile) + Dir.glob("{lib,test}/**/*")
end
