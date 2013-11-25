//
//  loggerTests.m
//  loggerTests
//
//  Created by Stephen Kuenzli on 11/23/13.
//  Copyright (c) 2013 Weblog-NG. All rights reserved.
//

#import <XCTest/XCTest.h>

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
    WNGLogger *logger = [[WNGLogger alloc] init];
    [logger sendMetric:@"metricName" metricValue:[NSNumber numberWithDouble:1234.5]];

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
