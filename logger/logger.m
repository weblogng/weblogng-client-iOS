//
//  logger.m
//  logger
//
//  Created by Stephen Kuenzli on 11/23/13.
//  Copyright (c) 2013, 2014 WeblogNG. All rights reserved.
//

#include <sys/time.h>
#import "logger.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPSessionManager.h"

static dispatch_queue_t api_log_message_send_queue() {
    static dispatch_queue_t api_log_message_send_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        api_log_message_send_queue = dispatch_queue_create("com.weblogng.api.log.messsage.send", DISPATCH_QUEUE_SERIAL);
    });
    
    return api_log_message_send_queue;
}


@implementation WNGLoggerAPIConnection

- (void) sendMetric:(NSString *)metricMessagePayload {
    NSLog(@"no-oping sendMetric : %@", metricMessagePayload);
    return;
}

@end

@interface WNGLoggerAPIConnectionHTTP : WNGLoggerAPIConnection

@property(copy) NSString *apiHost;

@end

@implementation WNGLoggerAPIConnectionHTTP

AFHTTPSessionManager *sessionManager;

@synthesize apiHost = _apiHost;

- (id)initWithConfig:(NSString *)apiHost {
    self = [super init];
    _apiHost = apiHost;

    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/", _apiHost]];

    sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];

    NSLog(@"Initialized %@", self);

    return self;
}


- (void) sendMetric:(NSString *)metricMessagePayload {
    
    dispatch_async(api_log_message_send_queue(), ^{
        NSString *url = [NSString stringWithFormat:@"https://%@/log/http", _apiHost];
        NSDictionary *parameters = @{@"message" : metricMessagePayload};
        
        NSLog(@"sending metric to %@ via http POST : %@", url, metricMessagePayload);
        
        sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [sessionManager POST:url parameters:parameters success:^(NSURLSessionDataTask *task, id response) {
            NSLog(@"sessionManager response: %@", response);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"sessionManager error: %@", error);
        }];
    });

    return;
}

- (NSString *)description {
    return [NSString stringWithFormat: @"[WNGLoggerAPIConnectionHTTP apiHost: %@, sessionManager: %@]", _apiHost, sessionManager];
}


@end


@implementation WNGLogger

static WNGLogger *sharedLogger = nil;

NSString *const API_HOST_PRODUCTION = @"api.weblogng.com";

NSMutableDictionary *timersByMetricName;

+ (WNGLogger *)initSharedLogger:(NSString *)apiKey {
    if(!sharedLogger){
        NSParameterAssert(apiKey);
        sharedLogger = [[WNGLogger alloc] initWithConfig:API_HOST_PRODUCTION apiKey:apiKey];
    }
    
    return sharedLogger;
}

+ (WNGLogger *)sharedLogger {
    return sharedLogger;
}

+ (void)resetSharedLogger {
    sharedLogger = nil;
}

- (id)initWithConfig:(NSString *)apiHost apiKey:(NSString *)apiKey application:(NSString *)application{
    self = [super init];
    timersByMetricName = [[NSMutableDictionary alloc] init];
    _apiHost = apiHost;
    _apiKey = apiKey;
    _application = application;
    
    if(_apiHost){
        _apiConnection = [[WNGLoggerAPIConnectionHTTP alloc] initWithConfig:_apiHost];
    }
    
    
    NSLog(@"Initialized %@", self);
    
    return self;
}

- (id)initWithConfig:(NSString *)apiHost apiKey:(NSString *)apiKey {
    return [self initWithConfig:apiHost apiKey:apiKey application:nil];
}

- (id)init {
    return [self initWithConfig:nil apiKey:nil application:nil];
}

@synthesize apiHost = _apiHost;
@synthesize apiKey = _apiKey;
@synthesize application = _application;
@synthesize apiConnection = _apiConnection;

- (BOOL)hasTimerFor:(NSString *)metricName {
    return [timersByMetricName objectForKey:metricName] ? TRUE : FALSE;
}

- (NSUInteger)timerCount {
    return [timersByMetricName count];
}

- (NSString *)description {
    return [NSString stringWithFormat: @"[Logger apiHost: %@, apiKey: %@, application: %@]",
            _apiHost, _apiKey, _application];
}

- (void) sendMetric: (NSString *) metricName metricValue:(NSNumber *)metricValue {
    NSParameterAssert(metricName);
    NSParameterAssert(metricValue);
    
    [_apiConnection sendMetric:[WNGLogger convertToMetricMessage:_apiKey metricName:metricName metricValue:metricValue]];
    return;
}

+ (NSString *) convertToMetricMessage: (NSString *)apiKey metricName:(NSString *)metricName metricValue:(NSNumber *)metricValue {
    NSString *message = [NSString stringWithFormat:@"v1.metric %@ %@ %@ %@",
                         apiKey, [WNGLogger sanitizeMetricName:metricName], [metricValue stringValue],
                         [WNGTime epochTimeInSeconds]];
    return message;
}

+ (NSString *)convertToMetricName: (NSURLRequest *)request {
    if(request){
        NSURL *url = [request URL];
        NSString *host = [url host];
        NSString *method = [request  HTTPMethod];
        NSString *metricName = [WNGLogger sanitizeMetricName: [NSString stringWithFormat:@"%@ %@", method, host]];
        
        return metricName;
    } else {
        return @"unknown";
    }
}

- (NSData *) makeLogMessage: (NSArray *)metrics {

    NSMutableDictionary *msg = [[NSMutableDictionary alloc] init];
    
    if(metrics){
        NSMutableArray *metricsCopy = [NSMutableArray arrayWithCapacity:[metrics count]];
        for(WNGMetric * metric in metrics){
            [metricsCopy addObject:[WNGMetric toDictionary: metric]];
        }
        
        [msg setObject:metricsCopy forKey:@"metrics"];
    }
    
    NSError* error;
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:msg
                                            options:NSJSONWritingPrettyPrinted
                                            error:&error];
    return jsonData;
}


- (WNGTimer *)recordStart:(NSString *)metricName {
    NSParameterAssert(metricName);
    
    WNGTimer *timer = [[WNGTimer alloc] init];
    [timer start];
    [timersByMetricName setObject:timer forKey:metricName];
    return timer;
}

- (WNGTimer *)recordFinish:(NSString *)metricName {
    NSParameterAssert(metricName);
    
    WNGTimer *timer = timersByMetricName[metricName];

    if(timer){
        [timer finish];
    } else {
        NSLog(@"recordFinish called for non-existent metric name: %@", metricName);
    }

    return timer;
}

+ (NSString *) sanitizeMetricName:(NSString *)metricName {
    NSString *pattern = @"[^\\w\\d\\:\\?\\=\\/\\\\._\\-\%]+";
    NSError *error = NULL;
    NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options: regexOptions error:&error];
    NSRange replacementRange = NSMakeRange(0, metricName.length);
    NSString *sanitizedMetricName = [regex stringByReplacingMatchesInString:metricName options:0 range:replacementRange withTemplate:@" "];
    return sanitizedMetricName;
}

- (WNGTimer *)recordFinishAndSendMetric:(NSString *)metricName {
    NSParameterAssert(metricName);
    
    WNGTimer *timer = [self recordFinish:metricName];

    if(timer){
        [self sendMetric:metricName metricValue:timer.elapsedTime];
        [timersByMetricName removeObjectForKey:metricName];
        return timer;
    }
    
    return timer;
}

- (WNGTimer *)executeWithTiming:(NSString*)metricName aBlock:(void(^)())block {
    NSParameterAssert(metricName);
    NSParameterAssert(block);
    
    [self recordStart:metricName];
    block();
    return [self recordFinishAndSendMetric:metricName];
}

@end

@implementation WNGTime

+ (NSNumber *)epochTimeInMilliseconds {
    struct timeval time;
    gettimeofday(&time, NULL);
    long long millis = (((long long) time.tv_sec) * 1000) + (time.tv_usec / 1000);

    return [NSNumber numberWithLongLong: millis];
}

+ (NSNumber *)epochTimeInSeconds {
    struct timeval time;
    gettimeofday(&time, NULL);
    long long seconds = ((long long) time.tv_sec);
    
    return [NSNumber numberWithLongLong: seconds];
}

@end

NSString *const SCOPE_APPLICATION = @"application";

@implementation WNGMetric

@synthesize name = _name;
@synthesize value = _value;
@synthesize timestamp = _timestamp;
@synthesize scope = _scope;
@synthesize category = _category;

- (id)init:(NSString *)name value:(NSNumber *)value {
    _name = name;
    _value = value;
    _timestamp = [WNGTime epochTimeInMilliseconds];
    _scope = SCOPE_APPLICATION;
    _category = nil;

    return self;
}

+ (NSDictionary *)toDictionary:(WNGMetric *)metric {
    return [NSDictionary dictionaryWithObjectsAndKeys:metric.name , @"name",
     metric.value, @"value",
    nil];
}

@end

@implementation WNGTimer

- (void) init: (NSNumber *)tStart tFinish:(NSNumber *)tFinish {
    _tStart = tStart;
    _tFinish = tFinish;
}

- (void) init:(NSNumber*)tStart {
    [self init:tStart tFinish:nil];
}

- (void) start {
    _tStart = [WNGTime epochTimeInMilliseconds];
}

- (void) finish {
    _tFinish = [WNGTime epochTimeInMilliseconds];
}

- (NSNumber *) elapsedTime {
    return [NSNumber numberWithLong:([_tFinish longValue] - [_tStart longValue])];
}

@end