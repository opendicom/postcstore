#import <Foundation/Foundation.h>

/**
 *  This protocol is used by the RSConnection to communicate with
 *  the RSRequest and write the received HTTP body data.
 *
 *  Note that multiple RSBodyWriter objects can be chained together
 *  internally e.g. to automatically decode gzip encoded content before
 *  passing it on to the RSRequest.
 *
 *  @warning These methods can be called on any GCD thread.
 */
@protocol RSBodyWriter <NSObject>
//returns YES on success
//or NO on failure and set the "error" argument which is guaranteed to be non-NULL.

//called before any body data is received.
- (BOOL)open:(NSError**)error;
//called whenever body data has been received.
- (BOOL)writeData:(NSData*)data error:(NSError**)error;
//called after all body data has been received.
- (BOOL)close:(NSError**)error;
@end
