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

@interface WNGTimer : NSObject

- (void)init:(NSNumber *)tStart tFinish:(NSNumber *)tFinish;

- (void)init:(NSNumber *)tStart;

@property(readonly) NSNumber *tStart;
@property(readonly) NSNumber *tFinish;

- (void)start;

- (void)finish;

- (NSNumber *)elapsedTime;

@end

@interface WNGLogger : NSObject

@property(copy) NSString *apiHost;
@property(copy) NSString *apiKey;
@property WNGLoggerAPIConnection *apiConnection;

- (void)sendMetric:(NSString *)metricName metricValue:(NSNumber *)theValue;

- (WNGTimer *)recordStart:(NSString *)metricName;

- (id)initWithConfig:(NSString *)apiHost apiKey:(NSString *)apiKey;

- (WNGTimer *)recordFinish:(NSString *)metricName;

+ (NSString *)sanitizeMetricName:(NSString *)metricName;

@end

@interface WNGTime : NSObject

+ (NSNumber *)epochTimeInSeconds;

@end
