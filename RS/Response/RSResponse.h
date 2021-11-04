#import "RSBodyReaderProtocol.h"

@interface RSResponse : NSObject <RSBodyReader>
{
    NSString* _type;
    NSUInteger _length;
    NSInteger _status;
    NSUInteger _maxAge;
    NSDate* _lastModified;
    NSString* _eTag;
    NSMutableDictionary* _headers;
    BOOL _chunked;
    BOOL _gzipped;
    
    BOOL _opened;
    NSMutableArray* _encoders;
    id<RSBodyReader> __unsafe_unretained _reader;
}

//wraps a single HTTP response.
//instantiated by the handler of the RS
//If a body is present, the methods from the RSBodyReader protocol will be called by the RSConnection to send it
//default implementation of the RSBodyReader protocol on the class simply returns an empty body
//can be created and used on any GCD thread

@property(nonatomic, copy) NSString* contentType;
//default value nil = no body
//must be set if body present

/**
 *  Sets the content length for the body of the response. If a body is present
 *  but this property is set to "NSUIntegerMax", this means the length of the body
 *  cannot be known ahead of time. Chunked transfer encoding will be
 *  automatically enabled by the RSConnection to comply with HTTP/1.1
 *  specifications.
 *
 *  The default value is "NSUIntegerMax" i.e. the response has no body or its length
 *  is undefined.
 */
@property(nonatomic) NSUInteger contentLength;

@property(nonatomic) NSInteger statusCode;//default value is 200 i.e. "OK"

@property(nonatomic) NSUInteger cacheControlMaxAge;//defaut = 0 "no-cache" time in seg

@property(nonatomic, retain) NSDate* lastModifiedDate;//default nil

@property(nonatomic, copy) NSString* eTag;//default nil

/**
 *  Enables gzip encoding for the response body.
 *
 *  The default value is NO.
 *
 *  @warning Enabling gzip encoding will remove any "Content-Length" header
 *  since the length of the body is not known anymore. The client will still
 *  be able to determine the body length when connection is closed per
 *  HTTP/1.1 specifications.
 */
@property(nonatomic, getter=isGZipContentEncodingEnabled) BOOL gzipContentEncodingEnabled;

@property(nonatomic, readonly) NSDictionary* additionalHeaders;
@property(nonatomic, readonly) BOOL usesChunkedTransferEncoding;

+ (instancetype)response;//creates empty response
- (instancetype)init;//designated initializer

//Pass a nil value to remove an additional header.
//Do not attempt to override the primary headers like "Content-Type", "ETag", etc...
- (void)setValue:(NSString*)value forAdditionalHeader:(NSString*)header;
- (BOOL)hasBody;
- (void)prepareForReading;
- (BOOL)performOpen:(NSError**)error;
- (void)performReadDataWithCompletion:(RSBodyReaderCompletionBlock)block;
- (void)performClose;
+ (instancetype)responseWithStatusCode:(NSInteger)statusCode;
+ (instancetype)responseWithRedirect:(NSURL*)location permanent:(BOOL)permanent;
- (instancetype)initWithStatusCode:(NSInteger)statusCode;
- (instancetype)initWithRedirect:(NSURL*)location permanent:(BOOL)permanent;

@end
