Gem::Specification.new do |s|
  s.name = "android_apk".freeze
  s.version = "0.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Kyosuke INOUE".freeze]
  s.date = "2016-03-01"
  s.description = "Library for analyzing Android APK application package. You can get any information of android apk file.".freeze
  s.email = "kyoro@hakamastyle.net".freeze
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
	s.files = `git ls-files`.split($/)
  s.homepage = "http://github.com/kyoro/android_apk".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.6.1".freeze
  s.summary = "Android APK file analyzer".freeze
end

