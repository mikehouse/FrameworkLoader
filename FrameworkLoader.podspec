
Pod::Spec.new do |s|

  s.name         = "FrameworkLoader"
  s.version      = "0.0.1"
  s.summary      = "Simple utility to download framework bundles from network"
  s.homepage     = "https://github.com/mikehouse/FrameworkLoader"
  s.license      = { :type => "MIT", :file => "LICENSE" } 
  s.author       = { "Demidov Mikhail" => "mike.house.nsk@gmail.com" }
    
  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.osx.deployment_target = '10.9'
  s.watchos.deployment_target = '2.0'

  s.source       = { :git => "https://github.com/mikehouse/FrameworkLoader.git", :tag => s.version.to_s }

  s.source_files  = "FrameworkLoader/**/*.{h,swift}"

  s.framework  = "Foundation"
  s.requires_arc = true

  s.dependency "SSZipArchive"

end
