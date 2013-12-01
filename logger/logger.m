//
//  logger.m
//  logger
//
//  Created by Stephen Kuenzli on 11/23/13.
//  Copyright (c) 2013 Weblog-NG. All rights reserved.
//

#import "logger.h"

@implementation WNGLoggerAPIConnection

- (void) sendMetric:(NSString *)metricMessagePayload; {
    NSLog(@"no-oping sendMetric : %@", metricMessagePayload);
    return;
}

@end


@interface WNGLoggerAPIConnectionHTTP : WNGLoggerAPIConnection


@end

@implementation WNGLoggerAPIConnectionHTTP

- (void) sendMetric: (NSString *) metricName metricValue:(NSNumber *)theValue {
    NSLog(@"sending %@ : %@", metricName, [theValue stringValue]);
    return;
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
        _apiConnection = [[WNGLoggerAPIConnectionHTTP alloc] init];
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

- (void) sendMetric: (NSString *) metricName metricValue:(NSNumber *)theValue {
    /* currently disabled for performance reasons
    NSLog(@"sending %@ : %@", metricName, [theValue stringValue]);
     */
    [_apiConnection sendMetric:[self convertToMetricMessage:metricName metricValue:theValue]];
    return;
}

- (NSString *) convertToMetricMessage: (NSString *) metricName metricValue:(NSNumber *)theValue {
    NSString *message = [NSString stringWithFormat:@"v1.metric %@ %@ %@ %@",
                         _apiKey, [WNGLogger sanitizeMetricName:metricName], [theValue stringValue], [WNGTime epochTimeInSeconds]];
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

+ (NSNumber *)epochTimeInSeconds {
    return [NSNumber numberWithLong:(long) [[NSDate date] timeIntervalSince1970]];
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
    _tStart = [WNGTime epochTimeInSeconds];
}

- (void) finish {
    _tFinish = [WNGTime epochTimeInSeconds];
}

- (NSNumber *) elapsedTime {
    return [NSNumber numberWithLong:[_tFinish longValue] - [_tStart longValue]];
}

@end