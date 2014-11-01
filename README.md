[![Build Status](https://travis-ci.org/weblogng/weblogng-client-iOS.svg?branch=master)](https://travis-ci.org/weblogng/weblogng-client-iOS)

## Usage ##

Using the [WeblogNG](https://www.weblogng.com) iOS client library follows an easy three-step process:

1. add the WNGLogger library dependency to your project
2. integrate the WNGLogger library into your application
3. create dashboard and charts with your metrics

### Add the WNGLogger library dependency to your project ###

The WNGLogger library is available via CocoaPods and is the recommended installation path.

You can install it by adding a WNGLogger dependency to your Podfile:

```
pod 'WNGLogger', :git => 'https://github.com/weblogng/weblogng-client-iOS.git', :tag => '0.7.0'
```

Execute ```pod install```. There should be some output like:
```
$ pod install
Analyzing dependencies
Pre-downloading: `WNGLogger` from `https://github.com/weblogng/weblogng-client-iOS.git`, tag `0.7.0`
Downloading dependencies
Using AFNetworking (2.3.1)
Installing WNGLogger 0.7.0
Generating Pods project
Integrating client project
```

### Integrate the WNGLogger library into your application ###

1. sign-up for [WeblogNG](https://www.weblogng.com)
2. add the WNGLogger header file
3. instantiate the Logger object using your api key
	1. find or generate an api key on your WeblogNG [account page](https://www.weblogng.com/app/account.html)
	2. recommendation: Store the sharedLogger in a convenient place to make it easy to use throughout the application
4. send metrics with the values recorded by your application

### Example ###

Here is some example code taken from the (super-simple) [WeblogNG iOS Sample App](https://github.com/weblogng/weblogng-client-ios-sample-app) for iOS that demonstrates the basic usage:

```Objective-C
#import "WNGAppDelegate.h"
#import WNGLogger/logger.h

@implementation WNGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *apiKey = @"specify your api key here";

    [WNGLogger initSharedLogger:apiKey];

    [self someIntensiveLogic];

    //time execution of an arbitrary block
    [[WNGLogger sharedLogger] executeWithTiming:@"sample-app-anExpensiveBlock" aBlock:^(void){
        int millis_to_sleep = 250 + arc4random_uniform(250);
        float seconds_to_sleep = ((float) millis_to_sleep) / 1000;
        [NSThread sleepForTimeInterval:seconds_to_sleep];
    }];

    return YES;
}

- (void) someIntensiveLogic {
    NSString *metricName = @"sample-app-someIntensiveLogic";
    [[WNGLogger sharedLogger] recordStart:metricName];

    int millis_to_sleep = 500 + arc4random_uniform(250);
    float seconds_to_sleep = ((float) millis_to_sleep) / 1000;

    [NSThread sleepForTimeInterval:seconds_to_sleep];

    [[WNGLogger sharedLogger] recordFinishAndSendMetric:metricName];
}

@end
```

### Create dashboard and charts with your application data ###

1. run your app, executing code timed with the library; this will report raw metric data to the WeblogNG api
2. go to [WeblogNG](https://www.weblogng.com), create a dashboard, and add a chart with your data


## References ##

* [WeblogNG iOS Sample App](https://github.com/weblogng/weblogng-client-ios-sample-app)
* [Specifying the version of a CocoaPod Using git](http://guides.cocoapods.org/using/the-podfile.html#from-a-podspec-in-the-root-of-a-library-repo)

