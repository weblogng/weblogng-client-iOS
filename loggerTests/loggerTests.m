//
//  loggerTests.m
//  loggerTests
//
//  Created by Stephen Kuenzli on 11/23/13.
//  Copyright (c) 2013 Weblog-NG. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#import "logger.h"

@interface loggerTests : XCTestCase

@end

@implementation loggerTests

WNGLogger *logger;


- (void)setUp
{
    [super setUp];
    logger = [[WNGLogger alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void) test_defaultState_of_Logger
{
    XCTAssertNil(logger.apiHost);
    XCTAssertNil(logger.apiKey);
}

- (void) test_sendMetric
{
    WNGLogger *logger = [WNGLogger initWithConfig:@"host" apiKey:@"api-key-1234"];
    
    NSString *metricName = @"metricName";
    NSNumber *metricValue = [NSNumber numberWithDouble:1234.5];
    NSString *expectedMessage = [NSString stringWithFormat: @"v1.metric %@ %@ %@",
                                 [logger apiKey], metricName, [metricValue stringValue]];
    
    id mock = [OCMockObject mockForClass:[WNGLoggerAPIConnection class]];
    
    [[mock expect] sendMetric:startsWith(expectedMessage)];
    
    logger.apiConnection = mock;
    
    [logger sendMetric:metricName metricValue:metricValue];
    
    [mock verify];
}

- (void) test_initWithConfig_initializes_the_logger_with_configuration
{
    NSString *expectedHost = @"host";
    NSString *expectedKey = @"key";
    
    WNGLogger *logger = [WNGLogger initWithConfig:expectedHost apiKey:expectedKey];
    
    
    XCTAssertEqualObjects(expectedHost, logger.apiHost);
    XCTAssertEqualObjects(expectedKey, logger.apiKey);
}

@end
