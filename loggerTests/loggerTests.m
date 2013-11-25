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

Logger *logger;


- (void)setUp
{
    [super setUp];
    logger = [[Logger alloc] init];
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
    Logger *logger = [[Logger alloc] init];
    [logger sendMetric:@"metricName" metricValue:[NSNumber numberWithDouble:1234.5]];

}

- (void)testExample
{
    XCTAssertTrue(true, @"implemented testExample");
    
}

@end
