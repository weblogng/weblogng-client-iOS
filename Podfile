# the best Podfile documentation is currently at https://github.com/CocoaPods/CocoaPods/wiki/A-Podfile

platform :ios, '8.0'
workspace 'WNGLogger'
xcodeproj 'logger'

pod "AFNetworking", "~> 2.4"
pod "JRSwizzle", "~> 1.0"

target :loggerTests, :exclusive => true do
    pod "OCMock", "~> 2.2"
    pod "OCHamcrest", "~> 3.0"
end

target :StressTests, :exclusive => true do
  pod "OCMock", "~> 2.2"
  pod "OCHamcrest", "~> 3.0"
end
