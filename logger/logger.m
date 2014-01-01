//
//  logger.m
//  logger
//
//  Created by Stephen Kuenzli on 11/23/13.
//  Copyright (c) 2013 Weblog-NG. All rights reserved.
//

#include <sys/time.h>
#import "logger.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPSessionManager.h"

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

    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/", _apiHost]];

    sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];

    NSLog(@"Initialized %@", self);

    return self;
}


- (void) sendMetric:(NSString *)metricMessagePayload {
    NSString *url = [NSString stringWithFormat:@"http://%@/log/http", _apiHost];
    NSDictionary *parameters = @{@"message" : metricMessagePayload};

    NSLog(@"sending metric to %@ via http POST : %@", url, metricMessagePayload);

    sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];

    [sessionManager POST:url parameters:parameters success:^(NSURLSessionDataTask *task, id response) {
        NSLog(@"sessionManager response: %@", response);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"sessionManager error: %@", error);
    }];

    return;
}

- (NSString *)description {
    return [NSString stringWithFormat: @"[WNGLoggerAPIConnectionHTTP apiHost: %@, sessionManager: %@]", _apiHost, sessionManager];
}


@end


@implementation WNGLogger

NSMutableDictionary *timersByMetricName;

- (id)initWithConfig:(NSString *)apiHost apiKey:(NSString *)apiKey {
    self = [super init];
    timersByMetricName = [NSMutableDictionary dictionaryWithDictionary:@{}];
    _apiHost = apiHost;
    _apiKey = apiKey;

    if(_apiHost){
        _apiConnection = [[WNGLoggerAPIConnectionHTTP alloc] initWithConfig:_apiHost];
    }

    NSLog(@"Initialized %@", self);

    return self;
}

- (id)init {
    return [self initWithConfig:nil apiKey:nil];
}

@synthesize apiHost = _apiHost;
@synthesize apiKey = _apiKey;
@synthesize apiConnection = _apiConnection;

- (BOOL)hasTimerFor:(NSString *)metricName {
    return [timersByMetricName objectForKey:metricName] ? TRUE : FALSE;
}

- (NSUInteger)timerCount {
    return [timersByMetricName count];
}

- (NSString *)description {
    return [NSString stringWithFormat: @"[Logger apiHost: %@, apiKey: %@]", _apiHost, _apiKey];
}

- (void) sendMetric: (NSString *) metricName metricValue:(NSNumber *)metricValue {
    [_apiConnection sendMetric:[WNGLogger convertToMetricMessage:_apiKey metricName:metricName metricValue:metricValue]];
    return;
}

+ (NSString *) convertToMetricMessage: (NSString *)apiKey metricName:(NSString *)metricName metricValue:(NSNumber *)metricValue {
    NSString *message = [NSString stringWithFormat:@"v1.metric %@ %@ %@ %@",
                         apiKey, [WNGLogger sanitizeMetricName:metricName], [metricValue stringValue],
                         [WNGTime epochTimeInSeconds]];
    return message;
}

- (WNGTimer *)recordStart:(NSString *)metricName {
    WNGTimer *timer = [[WNGTimer alloc] init];
    [timer start];
    [timersByMetricName setObject:timer forKey:metricName];
    return timer;
}

- (WNGTimer *)recordFinish:(NSString *)metricName {
    WNGTimer *timer = timersByMetricName[metricName];

    if(timer){
        [timer finish];
    } else {
        NSLog(@"recordFinish called for non-existent metric name: %@", metricName);
    }

    return timer;
}

+ (NSString *) sanitizeMetricName:(NSString *)metricName {
    NSString *pattern = @"[^\\w\\d_-]";
    NSError *error = NULL;
    NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options: regexOptions error:&error];
    NSRange replacementRange = NSMakeRange(0, metricName.length);
    NSString *sanitizedMetricName = [regex stringByReplacingMatchesInString:metricName options:0 range:replacementRange withTemplate:@"_"];
    return sanitizedMetricName;
}

- (WNGTimer *)recordFinishAndSendMetric:(NSString *)metricName {
    WNGTimer *timer = [self recordFinish:metricName];
    [self sendMetric:metricName metricValue:timer.elapsedTime];
    [timersByMetricName removeObjectForKey:metricName];
    return timer;
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

@implementation WNGTimer

@synthesize tStart = _tStart;
@synthesize tFinish = _tFinish;

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
    return [NSNumber numberWithLong:[_tFinish longValue] - [_tStart longValue]];
}

@end