//
//  logger.m
//  logger
//
//  Created by Stephen Kuenzli on 11/23/13.
//  Copyright (c) 2013 Weblog-NG. All rights reserved.
//

#import "logger.h"

@implementation WNGLogger

@synthesize apiHost = _apiHost;
@synthesize apiKey = _apiKey;


- (void) logSettings {
    NSLog(@"logger apiHost: %@ apiKey: %@", _apiHost, _apiKey);
}


- (void) sendMetric: (NSString *) metricName metricValue:(NSNumber *)theValue {
    NSLog(@"sending %@ : %@", metricName, [theValue stringValue]);
    return;
}

@end
