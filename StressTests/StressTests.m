//
//  StressTests.m
//  StressTests
//
//  Created by Stephen Kuenzli on 12/1/13.
//  Copyright (c) 2013 Weblog-NG. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#import "logger.h"
#import "NSURLConnection+WNGLogging.h"
#import "NSMutableArray_Shuffling.h"


@interface StressTests : XCTestCase

@end

@implementation StressTests

WNGLogger *logger;
NSString *apiHost;
NSString *apiKey;
id mockApiConnection;

- (void)setUp {
    [super setUp];
    apiHost = @"api.weblogng.com";
    apiKey = [NSString stringWithFormat: @"api-key-%d", arc4random_uniform(1000)];

    logger = [[WNGLogger alloc] initWithConfig:apiHost apiKey:apiKey];

    mockApiConnection = [OCMockObject niceMockForClass:[WNGLoggerAPIConnection class]];
    logger.apiConnection = mockApiConnection;
}

- (void)tearDown {
    [super tearDown];
}


- (void)test_large_cycles_of_recording_and_sending_metrics {

    for (int numCycles=0; numCycles<100; numCycles++) {

        NSUInteger numMetricsInCycle = 1000;
        NSMutableArray *metricNames = [NSMutableArray arrayWithCapacity:numMetricsInCycle];
        for(int i=0; i< numMetricsInCycle; i++){
            NSString *metricName = [NSString stringWithFormat:@"metric_%d", i];
            [logger recordStart:metricName];
            [metricNames addObject:metricName];
        }

        [metricNames shuffle];

        NSString *expectedMessage = [NSString stringWithFormat: @"v1.metric %@ ", [logger apiKey]];
        [[mockApiConnection expect] sendMetric:startsWith(expectedMessage)];

        for(NSString *metricName in metricNames){
            [logger recordFinishAndSendMetric:metricName];
        }

        assertThatUnsignedInteger([logger timerCount], equalToUnsignedInt(0));
        NSLog(@"completed record and send cycle %d", numCycles);
    }
}

@end

typedef void (^ResultHandlingBlock)(void);

@interface TestConnectionDelegate : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
    @property BOOL finishedLoading;
    @property BOOL failedWithError;
    @property (readwrite, copy) ResultHandlingBlock success;
    @property (readwrite, copy) ResultHandlingBlock failure;
@end

@implementation TestConnectionDelegate

@synthesize finishedLoading;
@synthesize failedWithError;

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"TestConnectionDelegate:connectionDidFinishLoading");
    [self setFinishedLoading:YES];
    self.success();
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"TestConnectionDelegate:didFailWithError");
    [self setFailedWithError:YES];
    self.failure();
}

//-(BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:
//(NSURLProtectionSpace *)protectionSpace {
//    return [protectionSpace.authenticationMethod
//            isEqualToString:NSURLAuthenticationMethodServerTrust];
//}

@end


@interface FunctionalTests : XCTestCase

@end


@implementation FunctionalTests

WNGLogger *logger;
NSString *apiHost;
NSString *apiKey;

- (void)setUp {
    [super setUp];
    [NSURLConnection wng_setLogging:YES];
    
    apiHost = @"api.weblogng.com";
    apiKey = @"93c5a127-e2a4-42cc-9cc6-cf17fdac8a7f";

    logger = [[WNGLogger alloc] initWithConfig:apiHost apiKey:apiKey];

}

- (void)tearDown {
    [super tearDown];
}


- (void)test_sending_metrics_over_http {

    for (int numCycles=0; numCycles<3; numCycles++) {

        NSUInteger numMetricsInCycle = 5;
        NSMutableArray *metricNames = [NSMutableArray arrayWithCapacity:numMetricsInCycle];
        for(int i=0; i< numMetricsInCycle; i++){
            NSString *metricName = [NSString stringWithFormat:@"WNGLogger.http_%d", i];
            [logger recordStart:metricName];
            [metricNames addObject:metricName];
        }

        [metricNames shuffle];

        for(NSString *metricName in metricNames){
            usleep(arc4random_uniform(10) * 100 * 1000);
            [logger recordFinishAndSendMetric:metricName];
        }



        NSLog(@"completed record and send cycle %d", numCycles);
    }
}

- (void) test_connection_delegate_invokes_success_for_good_url {
    [NSURLConnection wng_setLogging:YES];
    
	NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.google.com"]];
	
    XCTestExpectation *loadedExpectation = [self expectationWithDescription:@"connectionDidFinishLoading will be called"];

    TestConnectionDelegate *delegate = [[TestConnectionDelegate alloc] init];
    delegate.success = ^ {
        NSLog(@"executed success block for TestConnectionDelegate");
        [loadedExpectation fulfill];
    };

    delegate.failure = ^ {
        [loadedExpectation fulfill];
        XCTFail(@"failure handler was called, expected success");
    };

    [NSURLConnection connectionWithRequest:req delegate:delegate];
    
    
    [self waitForExpectationsWithTimeout:5 handler:Nil];
    
    XCTAssertTrue([delegate finishedLoading]);
    XCTAssertFalse([delegate failedWithError]);
}

- (void) test_connection_delegate_invokes_failure_for_bad_url {
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http:/does-not-exist.weblogng.com"]];
    
    XCTestExpectation *loadedExpectation = [self expectationWithDescription:@"didFailWithError will be called "];
    
    TestConnectionDelegate *delegate = [[TestConnectionDelegate alloc] init];
    delegate.success = ^ {
        XCTFail(@"success handler was called, expected failure");
        [loadedExpectation fulfill];
    };
    
    delegate.failure = ^ {
        NSLog(@"executed failure block for TestConnectionDelegate");
        [loadedExpectation fulfill];
    };
    
    [NSURLConnection connectionWithRequest:req delegate:delegate];
    
    
    [self waitForExpectationsWithTimeout:5 handler:Nil];
    
    XCTAssertFalse([delegate finishedLoading]);
    XCTAssertTrue([delegate failedWithError]);
    
}

- (void) test_timing_recorded_for_a_synchronous_request {
    [WNGLogger resetSharedLogger];
    WNGLogger *logger = [WNGLogger initSharedLogger:apiKey];
    assertThat(logger, isNot(nilValue()));
    
    //end setup
    
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.weblogng.com"]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    
    [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    
    //start tear-down
    [WNGLogger resetSharedLogger];
}

- (void) test_timing_recorded_for_a_asynchronous_request {
    [WNGLogger resetSharedLogger];
    WNGLogger *logger = [WNGLogger initSharedLogger:apiKey];
    assertThat(logger, isNot(nilValue()));
    
    //end setup
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.google.com"]];
    
    XCTestExpectation *loadedExpectation = [self expectationWithDescription:@"connectionDidFinishLoading will be called"];
    
    TestConnectionDelegate *delegate = [[TestConnectionDelegate alloc] init];
    delegate.success = ^ {
        NSLog(@"executed success block for TestConnectionDelegate");
        [loadedExpectation fulfill];
    };
    
    delegate.failure = ^ {
        [loadedExpectation fulfill];
        XCTFail(@"failure handler was called, expected success");
    };
    
    [NSURLConnection connectionWithRequest:request delegate:delegate];
    
    
    [self waitForExpectationsWithTimeout:5 handler:Nil];
    
    XCTAssertTrue([delegate finishedLoading]);
    XCTAssertFalse([delegate failedWithError]);

    
    //start tear-down
    [WNGLogger resetSharedLogger];
}


@end
