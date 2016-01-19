Pod::Spec.new do |s|
  s.name         = "json-schema-validator"
  s.version      = "0.0.2"
  s.summary      = "A json schema validator for iOS"

  s.description  = <<-DESC
		   json-schema-validator is iOS implementation the json-schema draft found at http://json-schema.org
                   DESC

  s.homepage     = "https://github.com/krpiatkowski/json-schema-validator"
  s.license      = 'MIT'
  s.author       = { "krpiatkowski" => "kr.piatkowski@gmail.com", "CodeReaper" => "jakobj@jakobj.dk" }
  s.platform     = :ios
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/krpiatkowski/json-schema-validator.git", :tag => "0.0.2" }

  s.source_files  = 'json-schema-validator/Classes/**/*.{h,m}'
  s.resources = ['json-schema-validator/Resources/*.json']

  s.requires_arc = true
end
