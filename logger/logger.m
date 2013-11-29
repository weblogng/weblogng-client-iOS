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

@synthesize apiHost = _apiHost;
@synthesize apiKey = _apiKey;
@synthesize apiConnection = _apiConnection;

- (NSString *)description {
    return [NSString stringWithFormat: @"[Logger apiHost: %@, apiKey: %@]", _apiHost, _apiKey];
}

- (void) sendMetric: (NSString *) metricName metricValue:(NSNumber *)theValue {
    NSLog(@"sending %@ : %@", metricName, [theValue stringValue]);
    [_apiConnection sendMetric:[self convertToMetricMessage:metricName metricValue:theValue]];
    return;
}

- (NSString *) convertToMetricMessage: (NSString *) metricName metricValue:(NSNumber *)theValue {
    NSString *message = [NSString stringWithFormat:@"v1.metric %@ %@ %@ %@",
                         _apiKey, [WNGLogger sanitizeMetricName:metricName], [theValue stringValue], [WNGTime epochTimeInSeconds]];
    return message;
}


+ (WNGLogger *) initWithConfig:(NSString *)apiHost apiKey:(NSString *)apiKey {
    WNGLogger *logger = [[WNGLogger alloc] init];
    logger.apiHost = apiHost;
    logger.apiKey = apiKey;
    logger.apiConnection = [[WNGLoggerAPIConnectionHTTP alloc] init];

    NSLog(@"Initialized %@", logger);
    
    return logger;
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

- (void) start {
    _tStart = [WNGTime epochTimeInSeconds];
}

- (void) finish {
    _tFinish = [WNGTime epochTimeInSeconds];
}

- (NSNumber *) elapsedTime {
    NSLog(@"tStart: %@ tFinish: %@", _tStart, _tFinish);
    return [NSNumber numberWithLong:[_tFinish longValue] - [_tStart longValue]];
}

@end