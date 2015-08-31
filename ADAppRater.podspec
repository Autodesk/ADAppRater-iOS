Pod::Spec.new do |s|
  
  s.name               = "ADAppRater"
  s.version            = "1.0.1"
  s.summary            = "ADAppRater promotes your apps by targeting satisfied users and asking them to rate your app"
  s.description        = <<-DESC
                        ADAppRater is a component intended to help you promote your apps in the App Store by targeting satisfied users and asking them to rate your app.
                        By pinpointing users who regularly engage with and think highly of your app, this approach is one of the best ways to earn positive app reviews. Following a simple installation process, you can see drastic improvements in your store rating in a matter of weeks.
                        Features:
                        1. Target only satisfied users to achieve a higher App Store rating
                        2. Collect valuable feedback and complaints from dissatisfied users
                        3. Easy to define usage parameters to target only experienced users
                        4. Supports multiple scenarios of significant events to target users who have completed a flow
                        5. You can create your own custom UI
                        DESC

  s.author             = { "Amir Shavit" => "amir.shavit@autodesk.com" }
  s.social_media_url   = "https://twitter.com/ashavit3"

  s.homepage           = "http://www.autodesk.com"
  s.screenshots        = [ "https://raw.githubusercontent.com/Autodesk/ADAppRater-iOS/master/Screenshots/Screenshot1_Satisfaction.png",
                           "https://raw.githubusercontent.com/Autodesk/ADAppRater-iOS/master/Screenshots/Screenshot2_Rate.png",
                           "https://raw.githubusercontent.com/Autodesk/ADAppRater-iOS/master/Screenshots/Screenshot3_Feedback.png" ]
  s.license            = { :type => "MIT", :file => "LICENCE.md" }

  s.source             = { :git => "https://github.com/Autodesk/ADAppRater-iOS.git", :tag => '1.0.1' }
  s.platform           = :ios, '7.0'
  s.source_files       = 'ADAppRater/**/*.{h,m}'
  
  s.frameworks         = 'Foundation', 'UIKit'
  s.requires_arc       = true

end
