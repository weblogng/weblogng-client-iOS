#import "NSURLConnection+WNGLogging.h"
#import "JRSwizzle.h"


/**
 * WNGLoggingDelegates is a private category used to track the WNGLoggingDelegate instances
 * created during interception.
 */
@interface NSURLConnection (WNGLoggingDelegates)
+ (NSMutableSet *)loggingDelegates;
@end

@implementation NSURLConnection (WNGLoggingDelegates)

//todo: investigate concurrency-safety of NSMutableSet further
static NSMutableSet *s_delegates = nil;

+ (NSMutableSet *)loggingDelegates
{
	if (! s_delegates)
		s_delegates = [[NSMutableSet alloc] init];
	return s_delegates;
}

@end

/**
 * NSURLConnection* delegate to handle callbacks first.
 * It will forward the callback to the original delegate after logging.
 */
@interface LoggingConnectionDelegate : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic) id <NSURLConnectionDelegate> actualDelegate;

@end

@implementation LoggingConnectionDelegate
@synthesize actualDelegate;

- (id) initWithActualDelegate:(id <NSURLConnectionDelegate>)actual
{
    self = [super init];
    if (self) {
        self.actualDelegate = actual;
        //todo: record start using an instance property
    }
    return self;
}

- (void) cleanup:(NSError *)error
{
    self.actualDelegate = nil;
    [[NSURLConnection loggingDelegates] removeObject:self];
}

// ------------------------------------------------------------------------
//
#pragma mark NSURLConnectionDelegate

//didFailWithError is called when the NSURLConnectionDelegate protocol
//encounters an error.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //todo: record finish
    if ([self.actualDelegate respondsToSelector:@selector(connection:didFailWithError:)])
    {
        [self.actualDelegate connection:connection didFailWithError:error];
    }
    
    [self cleanup:error];
}

// ------------------------------------------------------------------------
#pragma mark NSURLConnectionDataDelegate
//

//connectionDidFinishLoading is the final method called in the NSURLConnectionDataDelegate protocol
//when the request is successful.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //todo: record finish
    
    if ([self.actualDelegate respondsToSelector:@selector(connectionDidFinishLoading:)])
    {
        id <NSURLConnectionDataDelegate> actual = (id <NSURLConnectionDataDelegate>)self.actualDelegate;
        [actual connectionDidFinishLoading:connection];
    }
    
    [self cleanup:nil];
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
    
    NSData *responseData = [NSURLConnection wng_sendSynchronousRequest:request returningResponse:response error:error];
    
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
    [[NSURLConnection loggingDelegates] addObject:loggingDelegate];
    return [self wng_initWithRequest:request delegate:loggingDelegate];
}

- (id)wng_initWithRequest:(NSURLRequest *)request delegate:(id < NSURLConnectionDelegate >)delegate startImmediately:(BOOL)startImmediately
{
    NSLog(@"!!! wng_initWithRequest:request:delegate:startImmediately called");
    LoggingConnectionDelegate *loggingDelegate = [[LoggingConnectionDelegate alloc] initWithActualDelegate:delegate];
    [[NSURLConnection loggingDelegates] addObject:loggingDelegate];
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