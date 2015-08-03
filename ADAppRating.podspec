Pod::Spec.new do |s|
  
  s.name          = "ADAppRating"
  s.version       = "0.5.0"
  s.summary       = "An AutoCAD360 component that helps you promote your app and get good reviews on the App Store"
  s.homepage      = "http://www.autodesk.com"
  s.license       = 'MIT'
  s.author        = { "Amir Shavit" => "amir.shavit@autodesk.com" }
  s.source        = { :git => "https://git.autodesk.com/AutoCAD360/ADAppRating-iOS.git" }
  s.platform      = :ios, '7.0'
  s.source_files  = 'ADAppRating/**/*.{h,m}'
  s.frameworks    = 'Foundation', 'UIKit'
  s.requires_arc  = true

end
