Pod::Spec.new do |s|

  s.name         = "WNGLogger"
  s.version      = "0.6.0"
  s.summary      = "WNGLogger is an iOS client library to record and log metric data to Weblog-NG."

  s.description  = <<-DESC
                   WNGLogger is an iOS client library to record and log metric data via the
                   HTTP api of Weblog-NG.
                   DESC

  s.homepage     = "https://github.com/weblogng/weblogng-client-iOS"

  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE.txt' }

  s.authors       = { "Stephen Kuenzli" => "skuenzli@weblogng.com" }

  s.platform     = :ios, '6.0'

  s.source       = { :git => "https://github.com/weblogng/weblogng-client-iOS.git", :tag => "0.6.0" }

  s.source_files  = 'logger/*.{h,m}'

  s.dependency "AFNetworking", "~> 2.0"

end
