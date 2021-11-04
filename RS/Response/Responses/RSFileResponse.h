#import "RSResponse.h"


/**
 *  The RSFileResponse subclass of RSResponse reads the body
 *  of the HTTP response from a file on disk.
 *
 *  It will automatically set the contentType, lastModifiedDate and eTag
 *  properties of the RSResponse according to the file extension and
 *  metadata.
 */
@interface RSFileResponse : RSResponse

/**
 *  Creates a response with the contents of a file.
 */
+ (instancetype)responseWithFile:(NSString*)path;

/**
 *  Creates a response like +responseWithFile: and sets the "Content-Disposition"
 *  HTTP header for a download if the "attachment" argument is YES.
 */
+ (instancetype)responseWithFile:(NSString*)path isAttachment:(BOOL)attachment;

/**
 *  Creates a response like +responseWithFile: but restricts the file contents
 *  to a specific byte range.
 *
 *  See -initWithFile:byteRange: for details.
 */
+ (instancetype)responseWithFile:(NSString*)path byteRange:(NSRange)range;

/**
 *  Creates a response like +responseWithFile:byteRange: and sets the
 *  "Content-Disposition" HTTP header for a download if the "attachment"
 *  argument is YES.
 */
+ (instancetype)responseWithFile:(NSString*)path byteRange:(NSRange)range isAttachment:(BOOL)attachment;

/**
 *  Initializes a response with the contents of a file.
 */
- (instancetype)initWithFile:(NSString*)path;

/**
 *  Initializes a response like +responseWithFile: and sets the
 *  "Content-Disposition" HTTP header for a download if the "attachment"
 *  argument is YES.
 */
- (instancetype)initWithFile:(NSString*)path isAttachment:(BOOL)attachment;

/**
 *  Initializes a response like -initWithFile: but restricts the file contents
 *  to a specific byte range. This range should be set to (NSUIntegerMax, 0) for
 *  the full file, (offset, length) if expressed from the beginning of the file,
 *  or (NSUIntegerMax, length) if expressed from the end of the file. The "offset"
 *  and "length" values will be automatically adjusted to be compatible with the
 *  actual size of the file.
 *
 *  This argument would typically be set to the value of the byteRange property
 *  of the current RSRequest.
 */
- (instancetype)initWithFile:(NSString*)path byteRange:(NSRange)range;

/**
 *  This method is the designated initializer for the class.
 */
- (instancetype)initWithFile:(NSString*)path byteRange:(NSRange)range isAttachment:(BOOL)attachment;

@end
