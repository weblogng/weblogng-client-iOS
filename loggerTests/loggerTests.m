//
//  loggerTests.m
//  loggerTests
//
//  Created by Stephen Kuenzli on 11/23/13.
//  Copyright (c) 2013 Weblog-NG. All rights reserved.
//

#import <stdlib.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#import "logger.h"

@interface loggerTests : XCTestCase

@end

@implementation loggerTests

WNGLogger *logger;
NSString *apiHost;
NSString *apiKey;
id mockApiConnection;

- (void)setUp
{
    [super setUp];
    apiHost = @"api.weblogng.com";
    apiKey = [NSString stringWithFormat: @"api-key-%d", arc4random_uniform(1000)];
    mockApiConnection = [OCMockObject mockForClass:[WNGLoggerAPIConnection class]];

    logger = [WNGLogger initWithConfig:apiHost apiKey:apiKey];
    logger.apiConnection = mockApiConnection;
}

- (void)tearDown
{
    [super tearDown];
}

- (void) test_defaultState_of_Logger
{
    WNGLogger *logger = [[WNGLogger alloc] init];
    XCTAssertNil(logger.apiHost);
    XCTAssertNil(logger.apiKey);
}

- (void) test_Logger_properties
{
    WNGLogger *logger = [[WNGLogger alloc] init];
    NSString *expectedApiHost = @"api.weblogng.com";
    NSString *expectedApiKey = @"api-key-56789";
    WNGLoggerAPIConnection *expectedApiConnection = [OCMockObject mockForClass:[WNGLoggerAPIConnection class]];

    logger.apiHost = expectedApiHost;
    logger.apiKey = expectedApiKey;
    logger.apiConnection = expectedApiConnection;
    
    XCTAssertEqualObjects(logger.apiHost, expectedApiHost);
    XCTAssertEqualObjects(logger.apiKey, expectedApiKey);
    XCTAssertEqualObjects(logger.apiConnection, expectedApiConnection);
}

- (void) test_Logger_prints_property_data_in_description
{
    NSString *description = logger.description;
    assertThat(description, containsString(logger.apiHost));
    assertThat(description, containsString(logger.apiKey));
}


- (void) test_sendMetric_sends_reasonable_messages_to_connection
{
    
    NSString *metricName = @"metricName";
    NSNumber *metricValue = [NSNumber numberWithDouble:1234.5];
    NSString *nowStr = [[WNGTime epochTimeInSeconds] stringValue];
    NSString *mostSignificantBitsOfNow = [nowStr substringToIndex:8];
    
    NSString *expectedMessage = [NSString stringWithFormat: @"v1.metric %@ %@ %@ %@",
                                 [logger apiKey], metricName, [metricValue stringValue], mostSignificantBitsOfNow];
    
    [[mockApiConnection expect] sendMetric:startsWith(expectedMessage)];
    logger.apiConnection = mockApiConnection;
    
    [logger sendMetric:metricName metricValue:metricValue];
    
    [mockApiConnection verify];
}

- (void) test_sendMetric_sanitizes_metrics_before_sending
{
    WNGLogger *logger = [WNGLogger initWithConfig:@"host" apiKey:@"api-key-1234"];
    
    NSString *metricName = @"metricName.needs$sanitization";
    NSNumber *metricValue = [NSNumber numberWithDouble:1234.5];
    
    NSString *expectedMessage = [NSString stringWithFormat: @"v1.metric %@ %@ %@",
                                 [logger apiKey], [WNGLogger sanitizeMetricName:metricName], [metricValue stringValue]];
    
    [[mockApiConnection expect] sendMetric:startsWith(expectedMessage)];
    
    logger.apiConnection = mockApiConnection;
    
    [logger sendMetric:metricName metricValue:metricValue];
    
    [mockApiConnection verify];
}


- (void) test_sanitizeMetricName_sanitizes_invalid_names
{
    for(NSString *forbiddenChar in @[@".", @"!", @"," , @";", @":", @"?", @"/", @"\\", @"@", @"#", @"$", @"%", @"^", @"&", @"*", @"(", @")"]){
        NSString *actualMetricName = [WNGLogger sanitizeMetricName: [NSString stringWithFormat:@"metric-name_1%@2", forbiddenChar]];
        XCTAssertEqualObjects(actualMetricName, @"metric-name_1_2");
    }
}

- (void) test_initWithConfig_initializes_the_logger_with_configuration
{
    NSString *expectedHost = @"host";
    NSString *expectedKey = @"key";
    
    WNGLogger *logger = [WNGLogger initWithConfig:expectedHost apiKey:expectedKey];
    
    XCTAssertEqualObjects(expectedHost, logger.apiHost);
    XCTAssertEqualObjects(expectedKey, logger.apiKey);
}

- (void) test_getEpochTimeInSeconds
{
    NSNumber *actualTime = [WNGTime epochTimeInSeconds];
    double now = [[NSDate date] timeIntervalSince1970];
    
    assertThat(actualTime, closeTo(now, 1.1));
}

@end
