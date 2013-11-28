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


@implementation WNGLogger {}

@synthesize apiHost = _apiHost;
@synthesize apiKey = _apiKey;
@synthesize apiConnection = _apiConnection;

- (void) logSettings {
    NSLog(@"logger apiHost: %@ apiKey: %@", _apiHost, _apiKey);
}


- (void) sendMetric: (NSString *) metricName metricValue:(NSNumber *)theValue {
    NSLog(@"sending %@ : %@", metricName, [theValue stringValue]);
    [_apiConnection sendMetric:[self convertToMetricMessage:metricName metricValue:theValue]];
    return;
}

- (NSString *) convertToMetricMessage: (NSString *) metricName metricValue:(NSNumber *)theValue {
    NSString *message = [NSString stringWithFormat:@"v1.metric %@ %@ %@", _apiKey, metricName, [theValue stringValue]];
    return message;
}


+ (WNGLogger *) initWithConfig:(NSString *)apiHost apiKey:(NSString *)apiKey {
    WNGLogger *logger = [[WNGLogger alloc] init];
    logger.apiHost = apiHost;
    logger.apiKey = apiKey;
    logger.apiConnection = [[WNGLoggerAPIConnectionHTTP alloc] init];

    return logger;
}

@end
