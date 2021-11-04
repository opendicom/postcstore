#import "RSResponse.h"


/**
 *  The RSStreamBlock is called to stream the data for the HTTP body.
 *  The block must return either a chunk of data, an empty NSData when done, or
 *  nil on error and set the "error" argument which is guaranteed to be non-NULL.
 */
typedef NSData* (^RSStreamBlock)(NSError** error);

/**
 *  The RSAsyncStreamBlock works like the RSStreamBlock
 *  except the streamed data can be returned at a later time allowing for
 *  truly asynchronous generation of the data.
 *
 *  The block must call "completionBlock" passing the new chunk of data when ready,
 *  an empty NSData when done, or nil on error and pass a NSError.
 *
 *  The block cannot call "completionBlock" more than once per invocation.
 */
typedef void (^RSAsyncStreamBlock)(RSBodyReaderCompletionBlock completionBlock);

/**
 *  The RSStreamedResponse subclass of RSResponse streams
 *  the body of the HTTP response using a GCD block.
 */
@interface RSStreamedResponse : RSResponse

/**
 *  Creates a response with streamed data and a given content type.
 */
+ (instancetype)responseWithContentType:(NSString*)type streamBlock:(RSStreamBlock)block;

/**
 *  Creates a response with async streamed data and a given content type.
 */
+ (instancetype)responseWithContentType:(NSString*)type asyncStreamBlock:(RSAsyncStreamBlock)block;

/**
 *  Initializes a response with streamed data and a given content type.
 */
- (instancetype)initWithContentType:(NSString*)type streamBlock:(RSStreamBlock)block;

/**
 *  This method is the designated initializer for the class.
 */
- (instancetype)initWithContentType:(NSString*)type asyncStreamBlock:(RSAsyncStreamBlock)block;

@end
