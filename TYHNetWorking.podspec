Pod::Spec.new do |s|

  s.name         = "TYHNetWorking"
  s.version      = "0.0.1"
  s.summary      = "A short description of TYHNetWorking."
  s.homepage     = "https://github.com/tanyuehong/TYHNetWorking"
  s.license      = "MIT"
  s.author             = { "tanyuehong" => "957963898@qq.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/tanyuehong/TYHNetWorking.git", :tag => s.version }

  s.source_files  = "TYHNetWorking", "TYHNetWorking/**/*.{h,m}"
  s.dependency  'AFNetworking', '~> 3.1.0'

end
