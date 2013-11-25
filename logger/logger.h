//
//  logger.h
//  logger
//
//  Created by Stephen Kuenzli on 11/23/13.
//  Copyright (c) 2013 Weblog-NG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WNGLogger : NSObject { }

@property (copy) NSString *apiHost;
@property (copy) NSString *apiKey;

- (void)logSettings;

- (void)sendMetric:(NSString *)metricName metricValue:(NSNumber *)theValue;

@end
