//
//  logger.h
//  logger
//
//  Created by Stephen Kuenzli on 11/23/13.
//  Copyright (c) 2013 Weblog-NG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WNGLoggerAPIConnection : NSObject

- (void)sendMetric:(NSString *)metricMessagePayload;

@end


@interface WNGLogger : NSObject {
    
}

@property (copy) NSString *apiHost;
@property (copy) NSString *apiKey;
@property WNGLoggerAPIConnection *apiConnection;

- (void)logSettings;

- (void)sendMetric:(NSString *)metricName metricValue:(NSNumber *)theValue;

+ (WNGLogger *) initWithConfig:(NSString *)apiHost apiKey:(NSString *)apiKey;

@end

@interface WNGTime : NSObject {}

+ (NSNumber*) getEpochTimeInSeconds;

@end
