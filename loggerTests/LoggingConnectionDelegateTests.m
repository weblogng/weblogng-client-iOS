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
- (void)test_delegates_NSURLConnectionDelegate_connectionShouldUseCredentialStorage {
    
    id mockConnDelegate = [OCMockObject mockForProtocol:@protocol(NSURLConnectionDelegate)];
    id mockConn = [OCMockObject mockForClass:[NSURLConnection class]];
    
    BOOL shouldUseCredentials = arc4random() % 2;
    [[[mockConnDelegate stub] andReturnValue:OCMOCK_VALUE(shouldUseCredentials)] connectionShouldUseCredentialStorage:mockConn];
    
    delegate = [[LoggingConnectionDelegate alloc] initWithActualDelegate: mockConnDelegate];
    
    BOOL actualUseCredentials = [delegate connectionShouldUseCredentialStorage:mockConn];
    assertThatBool(actualUseCredentials, equalToBool(shouldUseCredentials));
    
    [mockConnDelegate verify];
}


//- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (void)test_delegates_NSURLConnectionDelegate_connection_willSendRequestForAuthenticationChallenge {
    
    id mockConnDelegate = [OCMockObject mockForProtocol:@protocol(NSURLConnectionDelegate)];
    id mockConn = [OCMockObject mockForClass:[NSURLConnection class]];
    NSURLAuthenticationChallenge *challenge = [[NSURLAuthenticationChallenge alloc] init];
    
    [[[mockConnDelegate expect] andDo:doNothingBlock] connection:mockConn willSendRequestForAuthenticationChallenge:challenge];
    
    delegate = [[LoggingConnectionDelegate alloc] initWithActualDelegate: mockConnDelegate];
    
    [delegate connection:mockConn willSendRequestForAuthenticationChallenge:challenge];
    
    [mockConnDelegate verify];
}

//- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace NS_DEPRECATED(10_6, 10_10, 3_0, 8_0, "Use -connection:willSendRequestForAuthenticationChallenge: instead.");
- (void)test_delegates_NSURLConnectionDelegate_connection_canAuthenticateAgainstProtectionSpace {
    
    id mockConnDelegate = [OCMockObject mockForProtocol:@protocol(NSURLConnectionDelegate)];
    id mockConn = [OCMockObject mockForClass:[NSURLConnection class]];
    id protectionSpace = [[NSURLProtectionSpace alloc] init];
    
    BOOL expectedCanAuth = arc4random() % 2;
    [[[mockConnDelegate stub] andReturnValue:OCMOCK_VALUE(expectedCanAuth)] connection:mockConn canAuthenticateAgainstProtectionSpace:protectionSpace];
    
    delegate = [[LoggingConnectionDelegate alloc] initWithActualDelegate: mockConnDelegate];
    
    BOOL actualCanAuth = [delegate connection:mockConn canAuthenticateAgainstProtectionSpace:protectionSpace];
    assertThatBool(actualCanAuth, equalToBool(expectedCanAuth));
    
    [mockConnDelegate verify];
}

//- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge NS_DEPRECATED(10_2, 10_10, 2_0, 8_0, "Use -connection:willSendRequestForAuthenticationChallenge: instead.");
- (void)test_delegates_NSURLConnectionDelegate_connection_didReceiveAuthenticationChallenge {
    
    id mockConnDelegate = [OCMockObject mockForProtocol:@protocol(NSURLConnectionDelegate)];
    id mockConn = [OCMockObject mockForClass:[NSURLConnection class]];
    id challenge = [[NSURLAuthenticationChallenge alloc] init];

    [[[mockConnDelegate stub] andDo:doNothingBlock] connection:mockConn didReceiveAuthenticationChallenge:challenge];
    
    delegate = [[LoggingConnectionDelegate alloc] initWithActualDelegate: mockConnDelegate];
    
    [delegate connection:mockConn didReceiveAuthenticationChallenge:challenge];
    
    [mockConnDelegate verify];
}

//- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge NS_DEPRECATED(10_2, 10_10, 2_0, 8_0, "Use -connection:willSendRequestForAuthenticationChallenge: instead.");
- (void)test_delegates_NSURLConnectionDelegate_connection_didCancelAuthenticationChallenge {
    
    id mockConnDelegate = [OCMockObject mockForProtocol:@protocol(NSURLConnectionDelegate)];
    id mockConn = [OCMockObject mockForClass:[NSURLConnection class]];
    id challenge = [[NSURLAuthenticationChallenge alloc] init];
    
    [[[mockConnDelegate stub] andDo:doNothingBlock] connection:mockConn didCancelAuthenticationChallenge:challenge];
    
    delegate = [[LoggingConnectionDelegate alloc] initWithActualDelegate: mockConnDelegate];
    
    [delegate connection:mockConn didCancelAuthenticationChallenge:challenge];
    
    [mockConnDelegate verify];
}

//- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response;
- (void)test_delegates_NSURLConnectionDataDelegate_connection_willSendRequest_redirectResponse {
    
    id mockConnDelegate = [OCMockObject mockForProtocol:@protocol(NSURLConnectionDataDelegate)];
    id mockConn = [OCMockObject mockForClass:[NSURLConnection class]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]];
    NSURLResponse *response = [[NSURLResponse alloc] init];
    
    [[[mockConnDelegate stub] andReturn:request] connection:mockConn willSendRequest:request redirectResponse:response];
    
    delegate = [[LoggingConnectionDelegate alloc] initWithActualDelegate: mockConnDelegate];
    
    NSURLRequest *actualRequest = [delegate connection:mockConn willSendRequest:request redirectResponse:response];
    assertThat(actualRequest, equalTo(request));
    
    [mockConnDelegate verify];
}


//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)test_delegates_NSURLConnectionDataDelegate_connection_didReceiveResponse {
    
    id mockConnDelegate = [OCMockObject mockForProtocol:@protocol(NSURLConnectionDataDelegate)];
    id mockConn = [OCMockObject mockForClass:[NSURLConnection class]];
    NSURLResponse *response = [[NSURLResponse alloc] init];
    
    [[[mockConnDelegate stub] andDo:doNothingBlock] connection:mockConn didReceiveResponse:response];
    
    delegate = [[LoggingConnectionDelegate alloc] initWithActualDelegate: mockConnDelegate];
    
    [delegate connection:mockConn didReceiveResponse:response];
    
    [mockConnDelegate verify];
}

//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
//
//- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request;
//- (void)connection:(NSURLConnection *)connection   didSendBodyData:(NSInteger)bytesWritten
// totalBytesWritten:(NSInteger)totalBytesWritten
//totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
//
//- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse;
//
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection;



@end
