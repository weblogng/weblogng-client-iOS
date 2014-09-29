//
//  NSURLConnection+WNGLogging.h
//

#import <Foundation/Foundation.h>

/**
 * WNGLogging is a NSURLConnection category enabling WeblogNG to log measurements automatically.
 */
@interface NSURLConnection (WNGLogging)
//TODO: decide and document whether these controls operate at a global or per request level
+ (void) wng_setLogging:(BOOL)enabled;
+ (BOOL) wng_loggingEnabled;
@end