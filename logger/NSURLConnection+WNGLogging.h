//
//  NSURLConnection+WNGLogging.h
//

#import <Foundation/Foundation.h>

/**
 * WNGLogging is a NSURLConnection category enabling WeblogNG to log measurements automatically.
 */
@interface NSURLConnection (WNGLogging)
+ (void) wng_setLogging:(BOOL)enabled;
+ (BOOL) wng_loggingEnabled;
@end

/**
 * NSURLConnection* delegate to handle callbacks first.
 * It will forward the callback to the original delegate after logging.
 */
@interface LoggingConnectionDelegate : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic) id <NSURLConnectionDelegate> actualDelegate;
@property (nonatomic) WNGTimer *timer;

/**
 * initalize the LoggingConnectionDelegate with an actual delegate to compose.
 */
- (id) initWithActualDelegate:(id <NSURLConnectionDelegate>)actual;

@end
