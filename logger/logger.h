//
//  logger.h
//
//  The logger header contains the central interfaces of the WeblogNG client library.
//
//  Created by Stephen Kuenzli on 11/23/13.
//  Copyright (c) 2013, 2014 WeblogNG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WNGLoggerAPIConnection : NSObject

- (void)sendMetric:(NSString *)metricMessagePayload;

- (void)send:(NSData *)logMessage;

@end

extern NSString *const WNG_SCOPE_APPLICATION;

extern NSString *const WNG_UNIT_MILLISECONDS;

@interface WNGMetric : NSObject

/**
 Create a WNGMetric initialized with the provided name and value, other metric properties will default to:
 
 * timestamp: defaults to `now`
 * scope: defaults to SCOPE_APPLICATION
 * category: defaults to `nil`
 
 @param name is the metric name
 @param value is the metric value; default unit is milliseconds
 */
- (id)init:(NSString *)name value:(NSNumber *)value;

/**
 Create a WNGMetric initialized with the provided values.
 
 @param name is the metric name
 @param value is the metric value
 @param unit is the unit of measure for the value; defaults to `nil`
 @param timestamp the epoch time in milliseconds at which the metric occurred; defaults to `nil`
 @param scope describes the scope or object the measurement is related to; defaults to `nil`
 @param category describes the category to which the measurement belongs, e.g. 'http request'; defaults to `nil`
 */
- (id)init:(NSString *)name
     value:(NSNumber *)value
      unit:(NSString *)unit
 timestamp:(NSNumber *) timestamp
     scope: (NSString *)scope
  category: (NSString *) category;

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSNumber *value;
@property(nonatomic, strong) NSString *unit;
@property(nonatomic, strong) NSNumber *timestamp;
@property(nonatomic, strong) NSString *scope;
@property(nonatomic, strong) NSString *category;

+ (NSDictionary *)toDictionary:(WNGMetric *)metric;

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


/**
 WNGLogger is the central interface in the WeblogNG client library.  Typical usage entails:
 1. initializing a shared logger with your api key during application initialization
 2. access the shared logger via the sharedLogger method
 3. use the record* and executeWithTiming methods to instrument your code
 */
@interface WNGLogger : NSObject

extern NSString *const API_HOST_PRODUCTION;

@property(copy) NSString *apiHost;
@property(copy) NSString *apiKey;
@property(copy) NSString *application;
@property(strong) WNGLoggerAPIConnection *apiConnection;

/**
 Initialize a logger with the provided config.
 
 @param apiHost is the WeblogNG api hostname
 @param apiKey is an account-specific api key for WeblogNG
 
 */
- (id)initWithConfig:(NSString *)apiHost apiKey:(NSString *)apiKey;

/**
 Initialize a logger with the provided config.
 
 @param apiHost is the WeblogNG api hostname
 @param apiKey is an account-specific api key for WeblogNG
 @param application is the name of the application
 
 */
- (id)initWithConfig:(NSString *)apiHost apiKey:(NSString *)apiKey application:(NSString *) application;


- (BOOL) hasTimerFor:(NSString *)metricName;

- (NSUInteger) timerCount;


- (NSData *) makeLogMessage: (NSArray *)metrics;


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
 Send a WNGMetric to the WeblogNG api
 
 @param metric is the WNGMetric to send
 
 @warning `metric` must not be `nil`
 */
- (void)sendMetric:(WNGMetric*) metric;

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
