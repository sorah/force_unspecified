
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "force_unspecified/version"

Gem::Specification.new do |spec|
  spec.name          = "force_unspecified"
  spec.version       = ForceUnspecified::VERSION
  spec.authors       = ["Sorah Fukumori"]
  spec.email         = ["sorah@cookpad.com"]

  spec.summary       = %q{Rack app redirects to a SAML IdP URL with changing NameIdPolicy in SAMLRequest to unspecified}
  spec.homepage      = "https://github.com/sorah/force_unspecified"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rack"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
