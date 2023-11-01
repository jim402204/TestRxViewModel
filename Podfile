# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

def shared_pods

  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # 關閉警告
  inhibit_all_warnings!

  # MVVM架構
  pod 'RxSwift', '6.2.0'
  pod 'RxCocoa', '6.2.0'
  pod 'Moya/RxSwift'
  
end

target 'TestRxViewModel' do
    shared_pods
end

# RxTest and RxBlocking make the most sense in the context of unit/integration tests
target 'TestRxViewModelTests' do
    pod 'RxBlocking'
    pod 'RxTest'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'

    end
  end
end
