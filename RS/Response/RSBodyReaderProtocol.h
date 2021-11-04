#import <Foundation/Foundation.h>

//passed by RS to the RSBodyReader object
typedef void (^RSBodyReaderCompletionBlock)(NSData* data, NSError* error);


@protocol RSBodyReader <NSObject>
//used by the connection
//multiple RSBodyReader objects can be chained together internally e.g. to automatically apply gzip encoding to the content before passing it on to the RSResponse. These methods can be called on any GCD thread.

@required

- (BOOL)open:(NSError**)error;//before any body data is sent

- (NSData*)readData:(NSError**)error;//called whenever body data is sent
//returns
//  a non-empty NSData if there is body data available,
//  or an empty NSData there is no more body data
//  or nil on error and set he "error" argument which is guaranteed to be non-NULL.

- (void)close;//called after all body data has been sent

@optional

//If this method is implemented, it will be preferred over -readData:.
//It must call the passed block when data is available, passing a non-empty NSData if there is body data available, or an empty NSData there is no more body data, or nil on error and pass an NSError along.
- (void)asyncReadDataWithCompletion:(RSBodyReaderCompletionBlock)block;

@end
