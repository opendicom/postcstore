#import "RS.h"
//instantiated by RS to handle each new HTTP connection.
// Each instance stays alive until the connection is closed.

typedef void (^ReadDataCompletionBlock)(BOOL success);
typedef void (^ReadHeadersCompletionBlock)(NSData* extraData);
typedef void (^ReadBodyCompletionBlock)(BOOL success);

typedef void (^WriteDataCompletionBlock)(BOOL success);
typedef void (^WriteHeadersCompletionBlock)(BOOL success);
typedef void (^WriteBodyCompletionBlock)(BOOL success);

@class RSHandler;


@interface RSConnection : NSObject

{
    NSData* _localAddress;
    NSData* _remoteAddress;
    CFSocketNativeHandle _socket;
    NSUInteger _bytesRead;
    NSUInteger _bytesWritten;
    
    CFHTTPMessageRef _requestMessage;
    RSRequest* _request;
    RSHandler* _handler;
    CFHTTPMessageRef _responseMessage;
    RSResponse* _response;
    NSInteger _statusCode;
    NSDate* _timestamp;
}

@property(nonatomic, readonly) NSData* localAddressData;//server  raw "struct sockaddr"
@property(nonatomic, readonly) NSString* localAddressString;//server address string

@property(nonatomic, readonly) NSData* remoteAddressData;//client raw "struct sockaddr"
@property(nonatomic, readonly) NSString* remoteAddressString;//client address string

@property(nonatomic, readonly) NSUInteger totalBytesRead;//received from client so far
@property(nonatomic, readonly) NSUInteger totalBytesWritten;//sent to client so far


//used once by RS before serving responses
+ (void)setHandlers:(NSArray*)handlers;

//called by RS for any new connection
- (id)initWithLocalAddress:(NSData*)localAddress
             remoteAddress:(NSData*)remoteAddress
                    socket:(CFSocketNativeHandle)socket;

//called by RSConnection if any error happens while validing or processing the request or if no RSResponse was generated during processing. If the request was invalid (e.g. the HTTP headers were malformed), the "request" argument will be nil.
- (void)abortRequest:(RSRequest*)request withStatusCode:(NSInteger)statusCode;

@end
