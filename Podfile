# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'ViiMe' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  # Pods for ViiMe
  pod 'Fabric' 
  pod "MIBadgeButton-Swift", :git => 'https://github.com/mustafaibrahim989/MIBadgeButton-Swift.git', :branch => 'master'
  pod 'Crashlytics'
  pod 'Firebase/Storage'
  pod 'ImagePicker'
  pod 'Firebase/Messaging'
  pod 'Firebase/Core'
  pod 'Firebase/Auth’
  pod 'FacebookCore'
  pod 'FacebookLogin'
  pod 'Firebase/Auth' 
  pod 'NotificationBannerSwift'
  pod 'Firebase/Database'
  pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'
  pod 'Kingfisher', '~> 3.0'	
  pod 'SCLAlertView’
  pod 'DZNEmptyDataSet’
  pod 'SnapKit', '~> 3.2.0’
  pod 'Onboard'
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.2'
        end
    end
end
end
