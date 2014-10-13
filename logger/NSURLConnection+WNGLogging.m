#import "logger.h"
#import "NSURLConnection+WNGLogging.h"
#import "JRSwizzle.h"


@implementation LoggingConnectionDelegate

@synthesize actualDelegate;
@synthesize timer;

- (id) initWithActualDelegate:(id <NSURLConnectionDelegate>)actual
{
    self = [super init];
    if (self) {
        self.actualDelegate = actual;
        self.timer = [[WNGTimer alloc] init];
        [[self timer] start];
        NSLog(@"!!! LoggingConnectionDelegate::initWithActualDelegate started timer");
    }
    return self;
}

- (void) cleanup:(NSError *)error
{
    self.actualDelegate = nil;
    self.timer = nil;
}

// ------------------------------------------------------------------------
//
#pragma mark NSURLConnectionDelegate

//didFailWithError is called when the NSURLConnectionDelegate protocol
//encounters an error.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"LoggingConnectionDelegate:connection:didFailWithError: was called");
    //todo: record finish
    if ([self.actualDelegate respondsToSelector:@selector(connection:didFailWithError:)])
    {
        [self.actualDelegate connection:connection didFailWithError:error];
    }
    
    [self cleanup:error];
}


- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
    if ([self.actualDelegate respondsToSelector:@selector(connectionShouldUseCredentialStorage:)])
    {
        return [self.actualDelegate connectionShouldUseCredentialStorage:connection];
    }
    return YES;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([self.actualDelegate respondsToSelector:@selector(connection:willSendRequestForAuthenticationChallenge:)])
    {
        [self.actualDelegate connection:connection willSendRequestForAuthenticationChallenge:challenge];
    }
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace NS_DEPRECATED(10_6, 10_10, 3_0, 8_0, "Use -connection:willSendRequestForAuthenticationChallenge: instead.")
{
    if ([self.actualDelegate respondsToSelector:@selector(connection:canAuthenticateAgainstProtectionSpace:)])
    {
        return [self.actualDelegate connection:connection canAuthenticateAgainstProtectionSpace:protectionSpace];
    }
    return NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge NS_DEPRECATED(10_2, 10_10, 2_0, 8_0, "Use -connection:willSendRequestForAuthenticationChallenge: instead.")
{
    if ([self.actualDelegate respondsToSelector:@selector(connection:didReceiveAuthenticationChallenge:)])
    {
        [self.actualDelegate connection:connection didReceiveAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge NS_DEPRECATED(10_2, 10_10, 2_0, 8_0, "Use -connection:willSendRequestForAuthenticationChallenge: instead.")
{
    if ([self.actualDelegate respondsToSelector:@selector(connection:didCancelAuthenticationChallenge:)])
    {
        [self.actualDelegate connection:connection didCancelAuthenticationChallenge:challenge];
    }
    
}

// ------------------------------------------------------------------------
#pragma mark NSURLConnectionDataDelegate
//

//connectionDidFinishLoading is the final method called in the NSURLConnectionDataDelegate protocol
//when the request is successful.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[self timer] finish];
    NSLog(@"!!! connectionDidFinishLoading elapsed time %@", timer.elapsedTime);
    
    WNGLogger *logger = [WNGLogger sharedLogger];
    if(logger)
    {
        NSString *metricName = [WNGLogger convertToMetricName:[connection currentRequest]];
        [logger sendMetric:metricName metricValue:timer.elapsedTime];
    }
    
    
    if ([self.actualDelegate respondsToSelector:@selector(connectionDidFinishLoading:)])
    {
        id <NSURLConnectionDataDelegate> actual = (id <NSURLConnectionDataDelegate>)self.actualDelegate;
        [actual connectionDidFinishLoading:connection];
    }
    
    [self cleanup:nil];
}



- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if ([self.actualDelegate respondsToSelector:@selector(connection:didReceiveData:)])
    {
        id <NSURLConnectionDataDelegate> actual = (id <NSURLConnectionDataDelegate>)self.actualDelegate;
        [actual connection:connection didReceiveData:data];
        
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([self.actualDelegate respondsToSelector:@selector(connection:didReceiveResponse:)])
    {

        id <NSURLConnectionDataDelegate> actual = (id < NSURLConnectionDataDelegate>)self.actualDelegate;
    
        [actual connection:connection didReceiveResponse:response];
    }
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    
    if ([self.actualDelegate respondsToSelector:@selector(connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)])
    {

    id <NSURLConnectionDataDelegate> actual = (id <NSURLConnectionDataDelegate>)self.actualDelegate;
    
    [actual connection:connection didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
    
}


- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {

    if ([self.actualDelegate respondsToSelector:@selector(connection:willSendRequest:redirectResponse:)])
    {
    id <NSURLConnectionDataDelegate> actual = (id <NSURLConnectionDataDelegate>)self.actualDelegate;
    
    return [actual connection:connection willSendRequest:request redirectResponse:response];
    }
    return request;
}


- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request {
    if ([self.actualDelegate respondsToSelector:@selector(connection:needNewBodyStream:)])
    {
    id <NSURLConnectionDataDelegate> actual = (id <NSURLConnectionDataDelegate>)self.actualDelegate;
    
    return [actual connection:connection needNewBodyStream:request];
    }
    return nil;
}


- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    if ([self.actualDelegate respondsToSelector:@selector(connection:willCacheResponse:)])
    {
    id <NSURLConnectionDataDelegate> actual = (id <NSURLConnectionDataDelegate>)self.actualDelegate;
    
    return [actual connection:connection willCacheResponse:cachedResponse];
    }
    return cachedResponse;
}
@end



@implementation NSURLConnection (WNGLogging)

// ------------------------------------------------------------------------
#pragma mark -
#pragma mark Swizzle NSURLConnection Class factory methods
//

+ (NSData *)wng_sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error
{
    NSLog(@"!!! wng_sendSynchronousRequest");
    WNGLogger *logger = [WNGLogger sharedLogger];
    
    WNGTimer *timer;

    
    if(logger){
        timer = [[WNGTimer alloc] init];
        [timer start];
    }
    
    NSData *responseData = [NSURLConnection wng_sendSynchronousRequest:request returningResponse:response error:error];

    if(logger){
        [timer finish];
        NSString *metricName = [WNGLogger convertToMetricName:request];
        [logger sendMetric:metricName metricValue:timer.elapsedTime];
    }
    
    return responseData;
}

+ (NSURLConnection *)wng_connectionWithRequest:(NSURLRequest *)request delegate:(id < NSURLConnectionDelegate >)delegate
{
    NSLog(@"!!! wng_connectionWithRequest");
    
    // connectionWithRequest:delegate calls initWithRequest:delegate internally, so no need to proxy the delegate.
    return [NSURLConnection wng_connectionWithRequest:request delegate:delegate];
}

+ (void)wng_sendAsynchronousRequest:(NSURLRequest *)request
                              queue:(NSOperationQueue *)queue
                  completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler
{
    NSLog(@"!!! wng_sendAsynchronousRequest");

    [NSURLConnection wng_sendAsynchronousRequest:request queue:queue completionHandler:handler];
}

// ------------------------------------------------------------------------
#pragma mark -
#pragma mark Swizzle NSURLConnection initialization methods

- (id)wng_initWithRequest:(NSURLRequest *)request delegate:(id < NSURLConnectionDelegate >)delegate
{
    NSLog(@"!!! wng_initWithRequest:request:delegate called");
    LoggingConnectionDelegate *loggingDelegate = [[LoggingConnectionDelegate alloc] initWithActualDelegate:delegate];
    return [self wng_initWithRequest:request delegate:loggingDelegate];
}

- (id)wng_initWithRequest:(NSURLRequest *)request delegate:(id < NSURLConnectionDelegate >)delegate startImmediately:(BOOL)startImmediately
{
    NSLog(@"!!! wng_initWithRequest:request:delegate:startImmediately called");
    LoggingConnectionDelegate *loggingDelegate = [[LoggingConnectionDelegate alloc] initWithActualDelegate:delegate];
    return [self wng_initWithRequest:request delegate:loggingDelegate startImmediately:startImmediately];
}


// ------------------------------------------------------------------------
#pragma mark -
#pragma mark Define utility functions to ease swizzling of NSURLConnection methods
+ (void) swizzleClassMethod:(SEL)from to:(SEL)to
{
    NSError *error = nil;
    BOOL swizzled = [NSURLConnection jr_swizzleClassMethod:from withClassMethod:to error:&error];
    if (!swizzled || error) {
        NSLog(@"!!! Failed in replacing method: %@", error);
    }
}

+ (void) swizzleInstanceMethod:(SEL)from to:(SEL)to
{
    NSError *error = nil;
    BOOL swizzled = [NSURLConnection jr_swizzleMethod:from withMethod:to error:&error];
    if (!swizzled || error) {
        NSLog(@"!!! Failed in replacing method: %@", error);
    }
}

static BOOL s_loggingEnabled = NO;

+ (BOOL) wng_loggingEnabled
{
    return s_loggingEnabled;
}


+ (void) wng_setLogging:(BOOL)enabled
{
    if (s_loggingEnabled == enabled)
        return;
    
    s_loggingEnabled = enabled;
    
    [NSURLConnection swizzleClassMethod:@selector(sendSynchronousRequest:returningResponse:error:)
                                     to:@selector(wng_sendSynchronousRequest:returningResponse:error:)];
    
    [NSURLConnection swizzleClassMethod:@selector(connectionWithRequest:delegate:)
                                     to:@selector(wng_connectionWithRequest:delegate:)];
    
    [NSURLConnection swizzleClassMethod:@selector(sendAsynchronousRequest:queue:completionHandler:)
                                     to:@selector(wng_sendAsynchronousRequest:queue:completionHandler:)];
    
    
    [NSURLConnection swizzleInstanceMethod:@selector(initWithRequest:delegate:)
                                        to:@selector(wng_initWithRequest:delegate:)];

    [NSURLConnection swizzleInstanceMethod:@selector(initWithRequest:delegate:startImmediately:)
                                        to:@selector(wng_initWithRequest:delegate:startImmediately:)];
    
}

@end