//
//  loggerTests.m
//  Tests of the WeblogNG Logger library for iOS.
//
//  Created by Stephen Kuenzli on 11/23/13.
//  Copyright (c) 2013, 2014 WeblogNG. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#define HC_SHORTHAND

#import <OCHamcrest/OCHamcrest.h>

#import "logger.h"

static const int TIMING_THRESHOLD_FOR_NOW_IN_MS = 25;
static const int TIMING_THRESHOLD_FOR_NOW_IN_S = 2;

double epochTimeInMilliseconds() {
    return [[NSDate date] timeIntervalSince1970] * 1000;
}

@interface WNGMetricTests : XCTestCase

@end

@implementation WNGMetricTests

- (void) test_init_metrics_using_the_minimal_required_data {
    
    u_int32_t numMetrics = 10;
    for(int i = 0; i<numMetrics; i++){
        NSString* name = [NSString stringWithFormat:@"metric_name_%d", arc4random_uniform(1000)];
        NSNumber* value = [NSNumber numberWithInt:arc4random_uniform(1000)];
        WNGMetric *metric = [[WNGMetric alloc] init:name value:value];
        
        assertThat(metric.name, equalTo(name));
        assertThat(metric.value, equalTo(value));
        assertThat(metric.unit, equalTo(UNIT_MILLISECONDS));
        assertThat(metric.timestamp, closeTo(epochTimeInMilliseconds(), TIMING_THRESHOLD_FOR_NOW_IN_MS));
        assertThat(metric.scope, equalTo(SCOPE_APPLICATION));
        assertThat(metric.category, is(nilValue()));
    }
}

- (void) test_init_metrics_with_all_supported_data {
    
    u_int32_t numMetrics = 10;
    for(int i = 0; i<numMetrics; i++){
        NSString *name = [NSString stringWithFormat:@"metric_name_%d", arc4random_uniform(1000)];
        NSNumber *value = [NSNumber numberWithInt:arc4random_uniform(1000)];
        NSString *unit = [NSString stringWithFormat:@"unit_%d", arc4random_uniform(1000)];
        NSNumber *timestamp = [WNGTime epochTimeInMilliseconds];
        NSString *scope = [NSString stringWithFormat:@"scope %d", arc4random_uniform(1000)];
        NSString *category = [NSString stringWithFormat:@"category %d", arc4random_uniform(1000)];
        
        WNGMetric *metric = [[WNGMetric alloc] init:name
                                              value:value
                                               unit:unit
                                          timestamp:timestamp
                                              scope: scope
                                           category: category];
        
        assertThat(metric.name, equalTo(name));
        assertThat(metric.value, equalTo(value));
        assertThat(metric.unit, equalTo(unit));
        assertThat(metric.timestamp, equalTo(timestamp));
        assertThat(metric.scope, equalTo(scope));
        assertThat(metric.category, equalTo(category));
    }
    
}

- (void) test_toDictionary_converts_metrics_correctly {
    u_int32_t numMetrics = 1000;
    for(int i = 0; i<numMetrics; i++){
        WNGMetric *expectedMetric = [WNGMetricTests makeMetric];
        NSDictionary *actualDict = [WNGMetric toDictionary:expectedMetric];
        [WNGMetricTests assertDictionaryRepresentsWNGMetric:actualDict expected:expectedMetric];
    }
}

+ (WNGMetric *) makeMetric {
    NSString* name = [NSString stringWithFormat:@"metric_name_%d", arc4random_uniform(1000)];
    NSNumber* value = [NSNumber numberWithInt:arc4random_uniform(1000)];
    NSNumber *timestamp = [WNGTime epochTimeInMilliseconds];
    
    NSString *scope;
    if(arc4random_uniform(10) > 5){
        scope = [NSString stringWithFormat:@"scope %d", arc4random_uniform(1000)];
    } else {
        scope = nil;
    }
    
    NSString *category;
    if(arc4random_uniform(10) > 5){
        category = [NSString stringWithFormat:@"category %d", arc4random_uniform(1000)];
    } else {
        category = nil;
    }
    
    return [[WNGMetric alloc] init:name value:value unit:UNIT_MILLISECONDS timestamp:timestamp scope:scope category:category];
}

+ (void) assertDictionaryRepresentsWNGMetric: (NSDictionary *) actualMetric expected:(WNGMetric *)expectedMetric {
    assertThat([actualMetric objectForKey:@"name"], equalTo(expectedMetric.name));
    assertThat([actualMetric objectForKey:@"value"], equalTo(expectedMetric.value));
    assertThat([actualMetric objectForKey:@"unit"], equalTo(expectedMetric.unit));
    assertThat([actualMetric objectForKey:@"timestamp"], equalTo(expectedMetric.timestamp));
    
    NSString *actualScope = [actualMetric objectForKey:@"scope"];
    if(expectedMetric.scope){
        assertThat(actualScope, equalTo(expectedMetric.scope));
    } else {
        assertThat(actualScope, is(nilValue()));
    }
    
    NSString *actualCategory = [actualMetric objectForKey:@"category"];
    if(expectedMetric.category){
        assertThat(actualCategory, equalTo(expectedMetric.category));
    } else {
        assertThat(actualCategory, is(nilValue()));
    }
}

@end


@interface WNGLoggerTests : XCTestCase

@end

@implementation WNGLoggerTests

WNGLogger *logger;
NSString *apiHost;
NSString *apiKey;
NSString *application;

id mockApiConnection;

- (void)setUp {
    [super setUp];
    
    apiHost = @"api.weblogng.com";
    apiKey = @"93c5a127-e2a4-42cc-9cc6-cf17fdac8a7f";
    application = @"test app";
 
    logger = [[WNGLogger alloc] initWithConfig:apiHost apiKey:apiKey application:application];

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
    assertThat(logger.application, is(nilValue()));
    assertThat(logger.apiConnection, is(nilValue()));
}

- (void)test_Logger_properties {
    WNGLogger *logger = [[WNGLogger alloc] init];
    NSString *expectedApiHost = @"api.weblogng.com";
    NSString *expectedApiKey = @"api-key-56789";
    NSString *expectedApp = @"application";
    WNGLoggerAPIConnection *expectedApiConnection = [OCMockObject mockForClass:[WNGLoggerAPIConnection class]];

    logger.apiHost = expectedApiHost;
    logger.apiKey = expectedApiKey;
    logger.application = expectedApp;
    logger.apiConnection = expectedApiConnection;
    
    assertThat(logger.apiHost, equalTo(expectedApiHost));
    assertThat(logger.apiKey, equalTo(expectedApiKey));
    assertThat(logger.apiConnection, equalTo(expectedApiConnection));
}

- (void)test_Logger_prints_property_data_in_description {
    NSString *description = logger.description;
    assertThat(description, containsString(logger.apiHost));
    assertThat(description, containsString(logger.apiKey));
    assertThat(description, containsString(logger.application));
}

- (void)test_initWithConfig_initializes_the_logger_with_configuration {
    NSString *expectedHost = @"host";
    NSString *expectedKey = @"key";

    WNGLogger *logger = [[WNGLogger alloc] initWithConfig:expectedHost apiKey:expectedKey];

    assertThat(logger.apiHost, equalTo(expectedHost));
    assertThat(logger.apiKey, equalTo(expectedKey));
    assertThat(logger.application, is(nilValue()));
    assertThat(logger.apiConnection, isNot(nil));
}

- (void)test_initWithConfig_initializes_the_logger_with_application_configuration {
    NSString *expectedHost = @"host";
    NSString *expectedKey = @"key";
    NSString *expectedApp = @"application";
    
    WNGLogger *logger = [[WNGLogger alloc] initWithConfig:expectedHost apiKey:expectedKey application:expectedApp];
    
    assertThat(logger.apiHost, equalTo(expectedHost));
    assertThat(logger.apiKey, equalTo(expectedKey));
    assertThat(logger.application, equalTo(expectedApp));
    assertThat(logger.apiConnection, isNot(nil));
}

- (void)test_convertToMetricMessage_constructs_a_proper_metric {
    
    NSString *metricName = [NSString stringWithFormat: @"metricName_%d", arc4random_uniform(10)];
    NSNumber *metricValue = [NSNumber numberWithDouble: arc4random_uniform(10)];
    
    NSString *message = [WNGLogger convertToMetricMessage: apiKey metricName:metricName metricValue:metricValue];
    
    NSArray *tokens = [message componentsSeparatedByString: @" "];
    
    //should look like:
    //v1.metric 93c5a127-e2a4-42cc-9cc6-cf17fdac8a7f metricName_8 3 1388529207
    //NSLog(@"actual message generated by convertToMetricMessage:\n%@", message);
    
    assertThat([NSNumber numberWithInt:(uint32_t) [tokens count]], equalToInt(5));
    assertThat(tokens[0], equalTo(@"v1.metric"));
    assertThat(tokens[1], equalTo(apiKey));
    assertThat(tokens[2], equalTo(metricName));
    assertThat(tokens[3], equalTo([metricValue stringValue]));
    
    double timestamp = [tokens[4] doubleValue];
    double now = (epochTimeInMilliseconds()) / 1000;
    assertThatLongLong(timestamp, closeTo(now, TIMING_THRESHOLD_FOR_NOW_IN_S));
}

- (void)test_createLogMessage_with_metrics {
    
    int numMetrics = arc4random_uniform(100);
    NSMutableArray *expectedMetrics = [NSMutableArray arrayWithCapacity:numMetrics];
    for (int i = 0; i < numMetrics; i++) {
        [expectedMetrics addObject:[WNGMetricTests makeMetric]];
    }
    
    
    NSData *logMessage = [logger makeLogMessage:expectedMetrics];
    assertThat(logMessage, isNot(nilValue()));
    //NSLog(@"logMessage (json): %@", [[NSString alloc] initWithData:logMessage encoding:NSUTF8StringEncoding]);
    
    NSError *error;
    NSDictionary* logMessageDict = [NSJSONSerialization JSONObjectWithData:logMessage
                                                         options:kNilOptions
                                                           error:&error];
    
    NSArray* actualMetrics = [logMessageDict objectForKey:@"metrics"];
    assertThatUnsignedInteger([actualMetrics count], equalToUnsignedInt([expectedMetrics count]));
    
    for (int i = 0; i < numMetrics; i++) {
        WNGMetric *expectedMetric = [expectedMetrics objectAtIndex:i];
        NSDictionary *actualMetric = [actualMetrics objectAtIndex:i];

        [WNGMetricTests assertDictionaryRepresentsWNGMetric:actualMetric expected: expectedMetric];        
        //NSLog(@"actual value: %@ expected value: %@", [actualMetric objectForKey:@"value"], expectedMetric.value);
    }
    
}

- (void) test_createLogMessage_with_metrics_repeatedly {
    for(int i = 0; i < 100; i++){
        [self test_createLogMessage_with_metrics];
    }
}

- (void)test_sendMetric_sends_reasonable_messages_to_connection {
    NSString *metricName = @"metricName";
    NSNumber *metricValue = [NSNumber numberWithDouble:1234.5];
    NSString *nowStr = [[WNGTime epochTimeInMilliseconds] stringValue];
    NSString *mostSignificantBitsOfNow = [nowStr substringToIndex:8];
    
    NSString *expectedMessage = [NSString stringWithFormat: @"v1.metric %@ %@ %@ %@",
                                 [logger apiKey], metricName, [metricValue stringValue], mostSignificantBitsOfNow];
    
    [[mockApiConnection expect] sendMetric:startsWith(expectedMessage)];

    [logger sendMetric:metricName metricValue:metricValue];
    
    [mockApiConnection verify];
}

- (void)test_sendMetric_allows_a_metricValue_of_zero {
    NSString *metricName = @"metricName.value.is.zero";
    NSNumber *metricValue = [NSNumber numberWithInt:0];
    
    NSString *expectedMessage = [NSString stringWithFormat: @"v1.metric %@ %@ %@",
                                 [logger apiKey], [WNGLogger sanitizeMetricName:metricName], [metricValue stringValue]];
    
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
    for(NSString *forbiddenChar in @[@"'", @"\"", @"\n"]){
        NSString *actualMetricName = [WNGLogger sanitizeMetricName: [NSString stringWithFormat:@"forbidden%@char", forbiddenChar]];
        assertThat(actualMetricName, equalTo(@"forbidden char"));
    }
}

- (void)test_sanitizeMetricName_allows_desired_metric_names {
    for(NSString *expectedMetricName in @[  @"GET localhost:8443"
                                     , @"POST www.weblogng.com"
                                     , @"PUT www.weblogng.com"
                                     , @"GET http://host.com/some/query/path?param=1"
                                     , @"GET https://host.com/some%20url%20encoded%20path?param=1"
                                     , @"GET t.co"
                                       ]){
        NSString *actualMetricName = [WNGLogger sanitizeMetricName: expectedMetricName];
        assertThat(actualMetricName, equalTo(expectedMetricName));
    }
}

- (void)test_convertToMetricName_builds_a_metric_name_from_provided_request_GET {
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://api.weblogng.com/some/service"]];
    NSString *actualMetricName = [WNGLogger convertToMetricName:req];
    
    assertThat(actualMetricName, equalTo(@"GET api.weblogng.com"));
}

- (void)test_convertToMetricName_builds_a_metric_name_from_provided_request_POST {
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://t.co"]];
    [req setHTTPMethod:@"POST"];
    
    NSString *actualMetricName = [WNGLogger convertToMetricName:req];
    
    assertThat(actualMetricName, equalTo(@"POST t.co"));
}

- (void)test_convertToMetricName_handles_nil_requests {
    assertThat([WNGLogger convertToMetricName:nil], equalTo(@"unknown"));
}

- (void)test_recordStart_creates_a_timer_and_starts_it {
    WNGTimer *timer = [logger recordStart: @"metric_name"];
    assertThat(timer.tStart, closeTo(epochTimeInMilliseconds(), TIMING_THRESHOLD_FOR_NOW_IN_MS));
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
    assertThat(finishedTimer.tFinish, closeTo(epochTimeInMilliseconds(), TIMING_THRESHOLD_FOR_NOW_IN_MS));
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
    assertThat(timer.tStart, closeTo(epochTimeInMilliseconds(), TIMING_THRESHOLD_FOR_NOW_IN_MS));
    assertThat(timer.tFinish, closeTo(epochTimeInMilliseconds(), TIMING_THRESHOLD_FOR_NOW_IN_MS));
    assertThat(timer.elapsedTime, closeTo(0, TIMING_THRESHOLD_FOR_NOW_IN_MS));
}

- (void)test_executeWithTiming_should_call_recordStart_invoke_provided_block_and_then_recordFinishAndSendMetric {
    NSString *metricName = @"metric.executeWithTiming";
    
    NSString *expectedMessage = [NSString stringWithFormat: @"v1.metric %@ %@",
                                 [logger apiKey],
                                 [WNGLogger sanitizeMetricName:metricName]];
    
    double tStart = epochTimeInMilliseconds();
    
    [[mockApiConnection expect] sendMetric:startsWith(expectedMessage)];
    
    WNGTimer *timer = [logger executeWithTiming:metricName aBlock: ^{
        for (int i = 0; i < 10; i++) {
            [NSThread sleepForTimeInterval:0.1];
        }
    }];

    
    [mockApiConnection verify];
    
    double tFinish = epochTimeInMilliseconds();
    
    assertThatBool([logger hasTimerFor: metricName], equalToBool(FALSE));
    assertThat(timer.tStart, closeTo(tStart, TIMING_THRESHOLD_FOR_NOW_IN_MS));
    assertThat(timer.tFinish, closeTo(tFinish, TIMING_THRESHOLD_FOR_NOW_IN_MS));
    assertThat(timer.elapsedTime, closeTo(tFinish - tStart, TIMING_THRESHOLD_FOR_NOW_IN_MS));
    
    NSLog(@"elapsedTime for executing block: %@ms", timer.elapsedTime);
}


/**
 * test the full lifecycle of the sharedLogger so that temporal effects are simpler to deal with.
 */
- (void)test_full_lifecycle_of_sharedLogger {
    //test initial state, init, and reset
    assertThat([WNGLogger sharedLogger], is(nilValue()));

    WNGLogger *logger = [WNGLogger initSharedLogger:apiKey];
    assertThat([logger apiHost], isNot(nil));
    assertThat([logger apiKey], equalTo(apiKey));
    
    [WNGLogger resetSharedLogger];
    assertThat([WNGLogger sharedLogger], is(nilValue()));
    
    //test repeated calls to init return the same logger
    logger = [WNGLogger initSharedLogger:apiKey];
    assertThat(logger, equalTo([WNGLogger initSharedLogger:apiKey]));
}

@end


@interface WNGTimeTests : XCTestCase

@end

@implementation WNGTimeTests

- (void)test_getEpochTimeInMilliseconds {
    NSNumber *actualTime = [WNGTime epochTimeInMilliseconds];
    double now = epochTimeInMilliseconds();

    assertThat(actualTime, closeTo(now, TIMING_THRESHOLD_FOR_NOW_IN_MS));
}

- (void)test_getEpochTimeInSeconds {
    NSNumber *actualTime = [WNGTime epochTimeInSeconds];
    double now = (epochTimeInMilliseconds()) / 1000;
    
    assertThat(actualTime, closeTo(now, TIMING_THRESHOLD_FOR_NOW_IN_S));

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
    assertThat(timer.tStart, closeTo([[WNGTime epochTimeInMilliseconds] doubleValue], TIMING_THRESHOLD_FOR_NOW_IN_MS));
}

- (void)test_finish_method_records_finish_time {
    [timer finish];
    assertThat(timer.tFinish, closeTo([[WNGTime epochTimeInMilliseconds] doubleValue], TIMING_THRESHOLD_FOR_NOW_IN_MS));
}

- (void)test_elapsedTime_is_computed_from_tStart_and_tFinish {
    [timer init:[NSNumber numberWithLong:42] tFinish:[NSNumber numberWithLong: 100]];

    assertThat([timer elapsedTime], equalTo([NSNumber numberWithLong: 58]));
}

@end

