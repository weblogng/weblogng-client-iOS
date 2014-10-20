//
//  logger.h
//  logger
//
//  Created by Stephen Kuenzli on 11/23/13.
//  Copyright (c) 2013, 2014 WeblogNG. All rights reserved.
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

/**
 Initialize a logger with the provided config.
 
 @param apiHost is the WeblogNG api hostname
 @param apiKey is an account-specific api key for WeblogNG
 
 */
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


/**
 Record the finish of the operation identified by metricName and send the timing information to the WeblogNG api.
 
 @param metricName identifies the operation being timed
 
 @warning `metricName` must not be `nil`.
 */
- (WNGTimer *)recordFinishAndSendMetric:(NSString *)metricName;

/**
 Execute a block identified by metricName and automatically record the elapsed time.
 
 @param metricName identifies the block to be executed
 @param block is the block to be executed
 
 @warning `metricName` must not be `nil`.
 @warning `block` must not be `nil`.
 */
- (WNGTimer *)executeWithTiming:(NSString*)metricName aBlock:(void(^)())block;


/**
 Send an arbitrary metric name and value to the WeblogNG api.
 
 @param metricName identifies the metric
 @param metricValue is the value to record
 
 @warning `metricName` must not be `nil`.
 @warning `metricValue` must not be `nil`.
 */
- (void)sendMetric:(NSString *)metricName metricValue:(NSNumber *)metricValue;

+ (NSString *)convertToMetricMessage: (NSString *)apiKey metricName:(NSString *)metricName metricValue:(NSNumber *)metricValue;

/**
 Converts the provided request to a metric name of the form <sanitized url host name>-<HTTP method>, 
 e.g. api_weblogng_com-POST.
 
 @param request is the NSURLRequest to convert
 
 @warning when `request` is `nil`, the returned metric name will be `unknown`
 */
+ (NSString *)convertToMetricName: (NSURLRequest *)request;

+ (NSString *)sanitizeMetricName:(NSString *)metricName;

/**
 * Initialize a shared (singleton) WNGLogger instance and makes it available via the sharedLogger function.  The
 * api host will be set to the production WeblogNG service.
 * 
 * @param apiKey is the WeblogNG api key to use for logging
 * @return an initialzed WNGLogger instance
 *
 * @warning `apiKey` must not be `nil`.
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
