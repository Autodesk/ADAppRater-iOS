Pod::Spec.new do |s|
  
  s.name               = "ADAppRater"
  s.version            = "1.0.0"
  s.summary            = "An AutoCAD360 component that helps you promote your app and get good reviews on the App Store"
 
  s.author             = { "Amir Shavit" => "amir.shavit@autodesk.com" }
  s.social_media_url   = "https://twitter.com/ashavit3"

  s.homepage           = "http://www.autodesk.com"
  s.screenshots        = [ "https://raw.githubusercontent.com/Autodesk/ADAppRater-iOS/master/Screenshots/Screenshot1_Satisfaction.png",
                           "https://raw.githubusercontent.com/Autodesk/ADAppRater-iOS/master/Screenshots/Screenshot2_Rate.png",
                           "https://raw.githubusercontent.com/Autodesk/ADAppRater-iOS/master/Screenshots/Screenshot3_Feedback.png" ]
  s.license            = { :type => "MIT", :file => "LICENCE.md" }

  s.source             = { :git => "https://github.com/Autodesk/ADAppRater-iOS.git", :tag => '1.0.0' }
  s.platform           = :ios, '7.0'
  s.source_files       = 'ADAppRater/**/*.{h,m}'
  
  s.frameworks         = 'Foundation', 'UIKit'
  s.requires_arc       = true

end
