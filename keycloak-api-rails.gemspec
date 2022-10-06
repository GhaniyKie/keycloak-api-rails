$:.push File.expand_path('lib', __dir__)

require 'keycloak-api-rails/version'

Gem::Specification.new do |spec|
  spec.name        = 'keycloak-api-rails'
  spec.version     = Keycloak::VERSION
  spec.authors     = ['Lorent Lempereur', 'Abdul Hakim Ghaniy']
  spec.email       = ['lorent.lempereur.dev@gmail.com', 'abdulhakimghaniy37@gmail.com']
  spec.homepage    = 'https://github.com/GhaniyKie/keycloak-api-rails'
  spec.summary     = 'Rails middleware that validates Authorization token emitted by Keycloak'
  spec.description = 'Rails middleware that validates Authorization token emitted by Keycloak'
  spec.license     = 'MIT'

  spec.files = `git ls-files -z`.split("\x0")
  spec.require_paths = ['lib']

  spec.add_dependency 'json-jwt'
  spec.add_dependency 'jwt'
  spec.add_dependency 'rails'

  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'timecop'
end
