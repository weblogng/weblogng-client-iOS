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

@property(nonatomic, strong) NSNumber *tStart;
@property(nonatomic, strong) NSNumber *tFinish;

- (void)start;

- (void)finish;

- (NSNumber *)elapsedTime;

@end


@interface WNGLogger : NSObject

extern NSString *const API_HOST_PRODUCTION;

@property(copy) NSString *apiHost;
@property(copy) NSString *apiKey;
@property(strong) WNGLoggerAPIConnection *apiConnection;

- (id)initWithConfig:(NSString *)apiHost apiKey:(NSString *)apiKey;

- (BOOL) hasTimerFor:(NSString *)metricName;

- (NSUInteger) timerCount;


/**
 Record the start of an operation identified by metricName.
 
 @param metricName identifies the operation being timed
 
 @warning `metricName` must not be `nil`.
 */
- (WNGTimer *)recordStart:(NSString *)metricName;

/**
 Record the finish of the operation identified by metricName.
 
 @param metricName identifies the operation being timed
 
 @warning `metricName` must not be `nil`.
 */
- (WNGTimer *)recordFinish:(NSString *)metricName;

- (WNGTimer *)recordFinishAndSendMetric:(NSString *)metricName;

/**
 Execute a block identified by metricName and automatically record the elapsed time.
 
 @param metricName identifies the block to be executed
 @param block is the block to be executed
 
 @warning `metricName` must not be `nil`.
 @warning `block` must not be `nil`.
 */
- (WNGTimer *)executeWithTiming:(NSString*)metricName aBlock:(void(^)())block;

- (void)sendMetric:(NSString *)metricName metricValue:(NSNumber *)theValue;

+ (NSString *)convertToMetricMessage: (NSString *)apiKey metricName:(NSString *)metricName metricValue:(NSNumber *)metricValue;

+ (NSString *)sanitizeMetricName:(NSString *)metricName;

/**
 * Initialize a shared (singleton) WNGLogger instance and makes it available via the sharedLogger function.  The
 * api host will be set to the production Weblog-NG service.
 * 
 * @param apiKey is the Weblog-NG api key to use for logging
 * @return an initialzed WNGLogger instance
 */
+ (WNGLogger *)initSharedLogger:(NSString *)apiKey;

/**
 * Gets the sharedLogger, if one has been initialized.  Initialize the sharedLoger with initSharedLogger.
 *
 * @return a reference to the shared WNGLogger instance
 */
+ (WNGLogger *)sharedLogger;


/**
 * Reset the reference to the sharedLogger back to nil.
 */
+ (void)resetSharedLogger;

@end

@interface WNGTime : NSObject

+ (NSNumber *)epochTimeInMilliseconds;
+ (NSNumber *)epochTimeInSeconds;

@end
