#import "RSResponse.h"


/**
 *  The RSDataResponse subclass of RSResponse reads the body
 *  of the HTTP response from memory.
 */
@interface RSDataResponse : RSResponse

/**
 *  Creates a response with data in memory and a given content type.
 */
+ (instancetype)responseWithData:(NSData*)data contentType:(NSString*)type;

/**
 *  This method is the designated initializer for the class.
 */
- (instancetype)initWithData:(NSData*)data contentType:(NSString*)type;

@end

@interface RSDataResponse (Extensions)

/**
 *  Creates a data response from text encoded using UTF-8.
 */
+ (instancetype)responseWithText:(NSString*)text;

/**
 *  Creates a data response from HTML encoded using UTF-8.
 */
+ (instancetype)responseWithHTML:(NSString*)html;

/**
 *  Creates a data response from an HTML template encoded using UTF-8.
 *  See -initWithHTMLTemplate:variables: for details.
 */
+ (instancetype)responseWithHTMLTemplate:(NSString*)path variables:(NSDictionary*)variables;

/**
 *  Creates a data response from a serialized JSON object and the default
 *  "application/json" content type.
 */
+ (instancetype)responseWithJSONObject:(id)object;

/**
 *  Creates a data response from a serialized JSON object and a custom
 *  content type.
 */
+ (instancetype)responseWithJSONObject:(id)object contentType:(NSString*)type;

/**
 *  Initializes a data response from text encoded using UTF-8.
 */
- (instancetype)initWithText:(NSString*)text;

/**
 *  Initializes a data response from HTML encoded using UTF-8.
 */
- (instancetype)initWithHTML:(NSString*)html;

/**
 *  Initializes a data response from an HTML template encoded using UTF-8.
 *
 *  All occurences of "%variable%" within the HTML template are replaced with
 *  their corresponding values.
 */
- (instancetype)initWithHTMLTemplate:(NSString*)path variables:(NSDictionary*)variables;

/**
 *  Initializes a data response from a serialized JSON object and the default
 *  "application/json" content type.
 */
- (instancetype)initWithJSONObject:(id)object;

/**
 *  Initializes a data response from a serialized JSON object and a custom
 *  content type.
 */
- (instancetype)initWithJSONObject:(id)object contentType:(NSString*)type;

@end
