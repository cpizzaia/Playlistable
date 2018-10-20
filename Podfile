# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Playlistable' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'Spotify-iOS-SDK', '0.25'
  pod 'Alamofire', '~> 4.5'
  pod 'SwiftyJSON', '3.1.4'
  pod 'ReSwift', '4.0.0'
  pod 'SDWebImage', '~>3.8'
  pod 'SVProgressHUD', '2.2.2'
  pod 'Locksmith', '4.0.0'
  pod 'Fabric', '1.7.5'
  pod 'Crashlytics', '3.10.1'
  pod 'SwiftLint', '0.25.0'
  pod 'EasyTipView', '2.0.0'
  pod 'SnapKit', '4.0.1'
  # Pods for Playlistable
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if ['EasyTipView'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.1'
      end
    end
  end
end
