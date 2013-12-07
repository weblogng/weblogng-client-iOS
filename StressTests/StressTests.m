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


@interface FunctionalTests : XCTestCase

@end


@implementation FunctionalTests

WNGLogger *logger;
NSString *apiHost;
NSString *apiKey;

- (void)setUp {
    [super setUp];
    apiHost = @"ec2-174-129-123-237.compute-1.amazonaws.com:9000";
    apiKey = @"93c5a127-e2a4-42cc-9cc6-cf17fdac8a7f";
//    apiKey = @"93c5a127-e2a4-42cc-9cc6-iOS";

    logger = [[WNGLogger alloc] initWithConfig:apiHost apiKey:apiKey];

}

- (void)tearDown {
    [super tearDown];
}


- (void)test_sending_metrics_over_http {

    for (int numCycles=0; numCycles<5; numCycles++) {

        NSUInteger numMetricsInCycle = 1;
        NSMutableArray *metricNames = [NSMutableArray arrayWithCapacity:numMetricsInCycle];
        for(int i=0; i< numMetricsInCycle; i++){
            NSString *metricName = [NSString stringWithFormat:@"metric_%d", i];
            [logger recordStart:metricName];
            [metricNames addObject:metricName];
        }

        [metricNames shuffle];

        NSString *expectedMessage = [NSString stringWithFormat: @"v1.metric %@ ", [logger apiKey]];
        [[mockApiConnection expect] sendMetric:startsWith(expectedMessage)];

        usleep(arc4random_uniform(10) * 100 * 1000);

        for(NSString *metricName in metricNames){
            [logger recordFinishAndSendMetric:metricName];
        }



        NSLog(@"completed record and send cycle %d", numCycles);
    }
}

@end
