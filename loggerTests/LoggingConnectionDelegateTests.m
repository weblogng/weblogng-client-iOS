//
//  LoggingConnectionDelegateTests.m
//  logger
//
//  Created by Stephen Kuenzli on 10/12/14.
//  Copyright (c) 2014 WeblogNG. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#define HC_SHORTHAND

#import <OCHamcrest/OCHamcrest.h>

#import "logger.h"
#import "NSURLConnection+WNGLogging.h"


@interface LoggingConnectionDelegateTests : XCTestCase

@end

typedef void (^OCMockCallback)(NSInvocation *invocation);


@implementation LoggingConnectionDelegateTests

LoggingConnectionDelegate *delegate;

OCMockCallback doNothingBlock = ^(NSInvocation *invocation) {
    
};

- (void)setUp {
    [super setUp];

    delegate = [[LoggingConnectionDelegate alloc] init];

}

- (void)test_initWithActualDelegate_stores_and_initializes_delegate_properly {

    NSNumber *now = [WNGTime epochTimeInMilliseconds];
    id mockConnDelegate = [OCMockObject mockForProtocol:@protocol(NSURLConnectionDelegate)];

    delegate = [[LoggingConnectionDelegate alloc] initWithActualDelegate: mockConnDelegate];

    assertThat([delegate actualDelegate], equalTo(mockConnDelegate));
    assertThat([delegate timer], isNot(nilValue()));
    assertThat([[delegate timer] tStart], is(greaterThanOrEqualTo(now)));    
}

//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

- (void)test_delegates_NSURLConnectionDelegate_connection_didFailWithError {
    
    id mockConnDelegate = [OCMockObject mockForProtocol:@protocol(NSURLConnectionDelegate)];
    id mockConn = [OCMockObject mockForClass:[NSURLConnection class]];
    NSError *error = [[NSError alloc] init];
    
    [[[mockConnDelegate expect] andDo:doNothingBlock] connection:mockConn didFailWithError:error];
    
    delegate = [[LoggingConnectionDelegate alloc] initWithActualDelegate: mockConnDelegate];
    
    [delegate connection:mockConn didFailWithError:error];
    
    [mockConnDelegate verify];
}

//- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection;
//- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
//- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace NS_DEPRECATED(10_6, 10_10, 3_0, 8_0, "Use -connection:willSendRequestForAuthenticationChallenge: instead.");
//- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge NS_DEPRECATED(10_2, 10_10, 2_0, 8_0, "Use -connection:willSendRequestForAuthenticationChallenge: instead.");
//- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge NS_DEPRECATED(10_2, 10_10, 2_0, 8_0, "Use -connection:willSendRequestForAuthenticationChallenge: instead.");


@end
