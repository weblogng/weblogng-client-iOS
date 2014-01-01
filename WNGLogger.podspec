Pod::Spec.new do |s|

  s.name         = "WNGLogger"
  s.version      = "0.3.0"
  s.summary      = "WNGLogger is an iOS client library to record and log metric data to Weblog-NG."

  s.description  = <<-DESC
                   WNGLogger is an iOS client library to record and log metric data via the
                   HTTP api of Weblog-NG.
                   DESC

  s.homepage     = "https://bitbucket.org/beardedrobotllc/weblog-ng-client-ios"

  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE.txt' }

  s.authors       = { "Stephen Kuenzli" => "skuenzli@qualimente.com" }

  s.platform     = :ios, '7.0'

  s.source       = { :git => "ssh://git@bitbucket.org/beardedrobotllc/weblog-ng-client-ios.git", :tag => "0.3.0" }

  s.source_files  = 'logger/*.{h,m}'

  s.dependency "AFNetworking", "2.0.3"

end
