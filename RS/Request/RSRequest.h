#import "RSBodyWriterProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  The RSRequest class is instantiated by the RSConnection
 *  after the HTTP headers have been received. Each instance wraps a single HTTP
 *  request. If a body is present, the methods from the RSBodyWriter
 *  protocol will be called by the RSConnection to receive it.
 *
 *  The default implementation of the RSBodyWriter protocol on the class  simply ignores the body data.
 *
 *  RSRequest instances can be created and used on any GCD thread.
 */

@interface RSRequest : NSObject <RSBodyWriter>
{
    NSString* _method;
    NSURL* _url;
    NSDictionary* _headers;
    NSString* _path;
    NSDictionary* _query;
    NSString* _type;
    BOOL _chunked;
    NSUInteger _length;
    NSDate* _modifiedSince;
    NSString* _noneMatch;
    NSRange _range;
    BOOL _gzipAccepted;
    NSString* _localAddressString;
    NSString* _remoteAddressString;
    
    BOOL _opened;
    NSMutableArray* _decoders;
    NSMutableDictionary* _attributes;
    id<RSBodyWriter> __unsafe_unretained _writer;
    
    //data
    NSString* _text;
    id _jsonObject;
}

@property(nonatomic, readonly) NSString* method;
@property(nonatomic, readonly) NSURL* URL;
@property(nonatomic, readonly) NSDictionary* headers;
@property(nonatomic, readonly) NSString* path;
@property(nonatomic, readonly) NSDictionary* query;
@property(nonatomic, readonly) NSString* contentType;
@property(nonatomic, readonly) NSUInteger contentLength;
@property(nonatomic, readonly) NSDate* ifModifiedSince;
@property(nonatomic, readonly) NSString* ifNoneMatch;
@property(nonatomic, readonly) NSRange byteRange;
@property(nonatomic, readonly) BOOL acceptsGzipContentEncoding;
@property(nonatomic, readonly) BOOL usesChunkedTransferEncoding;

//request keeps the string form and connection the data
//the string is available for request block
@property(nonatomic, readwrite) NSString* localAddressString;
@property(nonatomic, readwrite) NSString* remoteAddressString;

//data
@property(nonatomic, readonly) NSData* data;

//data for the request body interpreted as text
//If the content type of the body is not a text one, or if an error occurs, nil is returned.
//The text encoding used to interpret the data is extracted from the "Content-Type" header or defaults to UTF-8.
@property(nonatomic, readonly, nullable) NSString* text;

//data for the request body interpreted as a JSON object
//If the content type of the body is not JSON, or if an error occurs, nil is returned.
@property(nonatomic, readonly, nullable) id jsonObject;

//url encoded
//Returns the unescaped control names and values for the URL encoded form.
//The text encoding used to interpret the data is extracted from the "Content-Type" header or defaults to UTF-8.

@property(nonatomic, readonly) NSDictionary* arguments;

//JF
@property(nonatomic, readonly) int socket;


- (BOOL)hasBody;
- (BOOL)hasByteRange;

//designated initializer
- (instancetype)initWithMethod:(NSString*)method
                           url:(NSURL*)url
                       headers:(NSDictionary*)headers
                          path:(NSString*)path
                         query:(NSDictionary*)query
                         local:(NSString*)localAddressString
                        remote:(NSString*)remoteAddressString
                        socket:(int)socket;

- (id)attributeForKey:(NSString*)key;
- (void)prepareForWriting;
- (BOOL)performOpen:(NSError**)error;
- (BOOL)performWriteData:(NSData*)data error:(NSError**)error;
- (BOOL)performClose:(NSError**)error;
- (void)setAttribute:(id)attribute forKey:(NSString*)key;

@end

NS_ASSUME_NONNULL_END
