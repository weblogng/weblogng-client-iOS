//
//  loggerTests.m
//  Tests of the Weblog-NG Logger library for iOS.
//
//  Created by Stephen Kuenzli on 11/23/13.
//  Copyright (c) 2013 Weblog-NG. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#import "logger.h"
#import "NSMutableArray_Shuffling.h"

double epochTimeInSeconds() {
    return [[NSDate date] timeIntervalSince1970];
}


@interface WNGLoggerTests : XCTestCase

@end

@implementation WNGLoggerTests

WNGLogger *logger;
NSString *apiHost;
NSString *apiKey;
id mockApiConnection;

- (void)setUp {
    [super setUp];
    apiHost = @"api.weblogng.com";
    apiKey = [NSString stringWithFormat: @"api-key-%d", arc4random_uniform(1000)];

    logger = [[WNGLogger alloc] initWithConfig:apiHost apiKey:apiKey];

    mockApiConnection = [OCMockObject mockForClass:[WNGLoggerAPIConnection class]];
    logger.apiConnection = mockApiConnection;
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_defaultState_of_Logger {
    WNGLogger *logger = [[WNGLogger alloc] init];

    assertThat(logger.apiHost, is(nilValue()));
    assertThat(logger.apiKey, is(nilValue()));
    assertThat(logger.apiConnection, is(nilValue()));
}

- (void)test_Logger_properties {
    WNGLogger *logger = [[WNGLogger alloc] init];
    NSString *expectedApiHost = @"api.weblogng.com";
    NSString *expectedApiKey = @"api-key-56789";
    WNGLoggerAPIConnection *expectedApiConnection = [OCMockObject mockForClass:[WNGLoggerAPIConnection class]];

    logger.apiHost = expectedApiHost;
    logger.apiKey = expectedApiKey;
    logger.apiConnection = expectedApiConnection;
    
    assertThat(logger.apiHost, equalTo(expectedApiHost));
    assertThat(logger.apiKey, equalTo(expectedApiKey));
    assertThat(logger.apiConnection, equalTo(expectedApiConnection));
}

- (void)test_Logger_prints_property_data_in_description {
    NSString *description = logger.description;
    assertThat(description, containsString(logger.apiHost));
    assertThat(description, containsString(logger.apiKey));
}

- (void)test_initWithConfig_initializes_the_logger_with_configuration {
    NSString *expectedHost = @"host";
    NSString *expectedKey = @"key";

    WNGLogger *logger = [[WNGLogger alloc] initWithConfig:expectedHost apiKey:expectedKey];

    assertThat(logger.apiHost, equalTo(expectedHost));
    assertThat(logger.apiKey, equalTo(expectedKey));
    assertThat(logger.apiConnection, isNot(nil));
}

- (void)test_sendMetric_sends_reasonable_messages_to_connection {
    NSString *metricName = @"metricName";
    NSNumber *metricValue = [NSNumber numberWithDouble:1234.5];
    NSString *nowStr = [[WNGTime epochTimeInSeconds] stringValue];
    NSString *mostSignificantBitsOfNow = [nowStr substringToIndex:8];
    
    NSString *expectedMessage = [NSString stringWithFormat: @"v1.metric %@ %@ %@ %@",
                                 [logger apiKey], metricName, [metricValue stringValue], mostSignificantBitsOfNow];
    
    [[mockApiConnection expect] sendMetric:startsWith(expectedMessage)];

    [logger sendMetric:metricName metricValue:metricValue];
    
    [mockApiConnection verify];
}

- (void)test_sendMetric_sanitizes_metrics_before_sending {
    NSString *metricName = @"metricName.needs$sanitization";
    NSNumber *metricValue = [NSNumber numberWithDouble:1234.5];
    
    NSString *expectedMessage = [NSString stringWithFormat: @"v1.metric %@ %@ %@",
                                 [logger apiKey], [WNGLogger sanitizeMetricName:metricName], [metricValue stringValue]];

    [[mockApiConnection expect] sendMetric:startsWith(expectedMessage)];

    [logger sendMetric:metricName metricValue:metricValue];
    
    [mockApiConnection verify];
}


- (void)test_sanitizeMetricName_sanitizes_invalid_names {
    for(NSString *forbiddenChar in @[@".", @"!", @"," , @";", @":", @"?", @"/", @"\\", @"@", @"#", @"$", @"%", @"^", @"&", @"*", @"(", @")"]){
        NSString *actualMetricName = [WNGLogger sanitizeMetricName: [NSString stringWithFormat:@"metric-name_1%@2", forbiddenChar]];
        assertThat(actualMetricName, equalTo(@"metric-name_1_2"));
    }
}

- (void)test_recordStart_creates_a_timer_and_starts_it {
    WNGTimer *timer = [logger recordStart: @"metric_name"];
    assertThat(timer.tStart, closeTo(epochTimeInSeconds(), 1.1));
}

- (void)test_hasTimer_for_metric_name_returns_false_when_timer_does_not_exist {
    assertThatBool([logger hasTimerFor: @"does not exist"], equalToBool(FALSE));
}

- (void)test_timerCount_reports_the_correct_number_of_timers_in_progress {
    u_int32_t expectedTimerCount = arc4random_uniform(1000);

    for(int i = 0; i<expectedTimerCount; i++){
        [logger recordStart:[NSString stringWithFormat:@"metric_%d", i]];
    }

    assertThatUnsignedInteger([logger timerCount], equalToUnsignedInt(expectedTimerCount));

}

- (void)test_hasTimer_for_metric_name_returns_true_when_timer_does_exist {
    NSString *metricName = @"metric_that_exists";
    [logger recordStart:metricName];
    assertThatBool([logger hasTimerFor: metricName], equalToBool(TRUE));
}

- (void)test_recordFinish_records_the_current_time_when_called_for_a_given_metric_name {
    NSString *metricName = @"metric_name";
    WNGTimer *startedTimer = [logger recordStart:metricName];
    WNGTimer *finishedTimer = [logger recordFinish:metricName];

    assertThat(finishedTimer, equalTo(startedTimer));
    assertThat(finishedTimer, isNot(nil));
    assertThat(finishedTimer.tFinish, closeTo(epochTimeInSeconds(), 1.1));
}

- (void)test_recordFinishAndSendMetric_should_call_recordFinish_and_sendMetric {
    NSString *metricName = @"metric.recordFinishAndSend";
    [logger recordStart:metricName];

    NSString *expectedMessage = [NSString stringWithFormat: @"v1.metric %@ %@",
                    [logger apiKey],
                    [WNGLogger sanitizeMetricName:metricName]];

    [[mockApiConnection expect] sendMetric:startsWith(expectedMessage)];

    WNGTimer *timer = [logger recordFinishAndSendMetric:metricName];

    [mockApiConnection verify];

    assertThatBool([logger hasTimerFor: metricName], equalToBool(FALSE));
    assertThat(timer.tStart, closeTo(epochTimeInSeconds(), 1.1));
    assertThat(timer.tFinish, closeTo(epochTimeInSeconds(), 1.1));
    assertThat(timer.elapsedTime, closeTo(0, 0.5));
}

@end

@interface WNGTimeTests : XCTestCase

@end

@implementation WNGTimeTests

- (void)test_getEpochTimeInSeconds {
    NSNumber *actualTime = [WNGTime epochTimeInSeconds];
    double now = epochTimeInSeconds();

    assertThat(actualTime, closeTo(now, 1.1));
}

@end

@interface WNGTimerTests : XCTestCase

@end

@implementation WNGTimerTests

WNGTimer *timer;

- (void)setUp {
    [super setUp];

    timer = [[WNGTimer alloc] init];
    
}

- (void)test_default_state_of_Timer {
    assertThat(timer.tStart, is(nilValue()));
    assertThat(timer.tFinish, is(nilValue()));
}

- (void)test_start_method_records_start_time {
    [timer start];
    assertThat(timer.tStart, closeTo([[WNGTime epochTimeInSeconds] doubleValue], 1.1));
}

- (void)test_finish_method_records_finish_time {
    [timer finish];
    assertThat(timer.tFinish, closeTo([[WNGTime epochTimeInSeconds] doubleValue], 1.1));
}

- (void)test_elapsedTime_is_computed_from_tStart_and_tFinish {
    [timer init:[NSNumber numberWithLong:42] tFinish:[NSNumber numberWithLong: 100]];

    assertThat([timer elapsedTime], equalTo([NSNumber numberWithLong: 58]));
}

@end


@interface stressTests : XCTestCase
@end

@implementation stressTests {

}

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
