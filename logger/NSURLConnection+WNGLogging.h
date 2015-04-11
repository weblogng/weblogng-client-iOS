//
//  NSURLConnection+WNGLogging.h
//

#import <Foundation/Foundation.h>

/**
 * WNGLogging is a NSURLConnection category enabling WeblogNG to log measurements automatically.
 */
@interface NSURLConnection (WNGLogging)

/**
 Enable automatic logging of requests made via NSURLConnection.  Currently, once logging is enabled, it cannnot
 be disabled.
 */
+ (void) wng_enableLogging;

/**
 wng_isLoggingEnabled returns whether automatic logging of NSURLConnection is enabled.
 */
+ (BOOL) wng_isLoggingEnabled;
@end

/**
 * NSURLConnection* delegate to handle callbacks first.
 * It will forward the callback to the original delegate after logging.
 */
@interface LoggingConnectionDelegate : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, retain) id <NSURLConnectionDelegate> actualDelegate;
@property (nonatomic, retain) WNGTimer *timer;

/**
 * initalize the LoggingConnectionDelegate with an actual delegate to compose.
 */
- (id) initWithActualDelegate:(id <NSURLConnectionDelegate>)actual;

@end
