# the best Podfile documentation is currently at https://github.com/CocoaPods/CocoaPods/wiki/A-Podfile

platform :ios, '7.0'
xcodeproj 'logger'

pod "AFNetworking", "2.0.3"

#pod "SocketRocket", "0.3.1-beta2"

target :loggerTests, :exclusive => true do
    pod "OCMock", "~> 2.2"
    pod "OCHamcrest", "~> 3.0"
end

target :StressTests, :exclusive => true do
  pod "OCMock", "~> 2.2"
  pod "OCHamcrest", "~> 3.0"
end