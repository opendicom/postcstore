#import "RSDataResponse.h"

// http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
// http://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml


/**
 *  Convenience constants for "informational" HTTP status codes.
 */
typedef NS_ENUM(NSInteger, RSInformationalHTTPStatusCode) {
    kRSHTTPStatusCode_Continue = 100,
    kRSHTTPStatusCode_SwitchingProtocols = 101,
    kRSHTTPStatusCode_Processing = 102
};

/**
 *  Convenience constants for "successful" HTTP status codes.
 */
typedef NS_ENUM(NSInteger, RSSuccessfulHTTPStatusCode) {
    kRSHTTPStatusCode_OK = 200,
    kRSHTTPStatusCode_Created = 201,
    kRSHTTPStatusCode_Accepted = 202,
    kRSHTTPStatusCode_NonAuthoritativeInformation = 203,
    kRSHTTPStatusCode_NoContent = 204,
    kRSHTTPStatusCode_ResetContent = 205,
    kRSHTTPStatusCode_PartialContent = 206,
    kRSHTTPStatusCode_MultiStatus = 207,
    kRSHTTPStatusCode_AlreadyReported = 208
};

/**
 *  Convenience constants for "redirection" HTTP status codes.
 */
typedef NS_ENUM(NSInteger, RSRedirectionHTTPStatusCode) {
    kRSHTTPStatusCode_MultipleChoices = 300,
    //kRSHTTPStatusCode_MovedPermanently = 301,
    kRSHTTPStatusCode_Found = 302,
    kRSHTTPStatusCode_SeeOther = 303,
    kRSHTTPStatusCode_NotModified = 304,
    kRSHTTPStatusCode_UseProxy = 305,
    //kRSHTTPStatusCode_TemporaryRedirect = 307,
    kRSHTTPStatusCode_PermanentRedirect = 308
};

/**
 *  Convenience constants for "client error" HTTP status codes.
 */
typedef NS_ENUM(NSInteger, RSClientErrorHTTPStatusCode) {
    kRSHTTPStatusCode_BadRequest = 400,
    kRSHTTPStatusCode_Unauthorized = 401,
    kRSHTTPStatusCode_PaymentRequired = 402,
    kRSHTTPStatusCode_Forbidden = 403,
    //kRSHTTPStatusCode_NotFound = 404,
    kRSHTTPStatusCode_MethodNotAllowed = 405,
    kRSHTTPStatusCode_NotAcceptable = 406,
    kRSHTTPStatusCode_ProxyAuthenticationRequired = 407,
    kRSHTTPStatusCode_RequestTimeout = 408,
    kRSHTTPStatusCode_Conflict = 409,
    kRSHTTPStatusCode_Gone = 410,
    kRSHTTPStatusCode_LengthRequired = 411,
    kRSHTTPStatusCode_PreconditionFailed = 412,
    kRSHTTPStatusCode_RequestEntityTooLarge = 413,
    kRSHTTPStatusCode_RequestURITooLong = 414,
    kRSHTTPStatusCode_UnsupportedMediaType = 415,
    kRSHTTPStatusCode_RequestedRangeNotSatisfiable = 416,
    kRSHTTPStatusCode_ExpectationFailed = 417,
    kRSHTTPStatusCode_UnprocessableEntity = 422,
    kRSHTTPStatusCode_Locked = 423,
    //kRSHTTPStatusCode_FailedDependency = 424,
    kRSHTTPStatusCode_UpgradeRequired = 426,
    kRSHTTPStatusCode_PreconditionRequired = 428,
    kRSHTTPStatusCode_TooManyRequests = 429,
    kRSHTTPStatusCode_RequestHeaderFieldsTooLarge = 431
};

/**
 *  Convenience constants for "server error" HTTP status codes.
 */
typedef NS_ENUM(NSInteger, RSServerErrorHTTPStatusCode) {
    kRSHTTPStatusCode_InternalServerError = 500,
    kRSHTTPStatusCode_NotImplemented = 501,
    kRSHTTPStatusCode_BadGateway = 502,
    kRSHTTPStatusCode_ServiceUnavailable = 503,
    kRSHTTPStatusCode_GatewayTimeout = 504,
    kRSHTTPStatusCode_HTTPVersionNotSupported = 505,
    kRSHTTPStatusCode_InsufficientStorage = 507,
    kRSHTTPStatusCode_LoopDetected = 508,
    kRSHTTPStatusCode_NotExtended = 510,
    kRSHTTPStatusCode_NetworkAuthenticationRequired = 511
};


/**
 *  The RSDataResponse subclass of RSDataResponse generates
 *  an HTML body from an HTTP status code and an error message.
 */
@interface RSErrorResponse : RSDataResponse

/**
 *  Creates a client error response with the corresponding HTTP status code.
 */
+ (instancetype)responseWithClientError:(RSClientErrorHTTPStatusCode)errorCode message:(NSString*)format, ... NS_FORMAT_FUNCTION(2,3);

/**
 *  Creates a server error response with the corresponding HTTP status code.
 */
+ (instancetype)responseWithServerError:(RSServerErrorHTTPStatusCode)errorCode message:(NSString*)format, ... NS_FORMAT_FUNCTION(2,3);

/**
 *  Creates a client error response with the corresponding HTTP status code
 *  and an underlying NSError.
 */
+ (instancetype)responseWithClientError:(RSClientErrorHTTPStatusCode)errorCode underlyingError:(NSError*)underlyingError message:(NSString*)format, ... NS_FORMAT_FUNCTION(3,4);

/**
 *  Creates a server error response with the corresponding HTTP status code
 *  and an underlying NSError.
 */
+ (instancetype)responseWithServerError:(RSServerErrorHTTPStatusCode)errorCode underlyingError:(NSError*)underlyingError message:(NSString*)format, ... NS_FORMAT_FUNCTION(3,4);

/**
 *  Initializes a client error response with the corresponding HTTP status code.
 */
- (instancetype)initWithClientError:(RSClientErrorHTTPStatusCode)errorCode message:(NSString*)format, ... NS_FORMAT_FUNCTION(2,3);

/**
 *  Initializes a server error response with the corresponding HTTP status code.
 */
- (instancetype)initWithServerError:(RSServerErrorHTTPStatusCode)errorCode message:(NSString*)format, ... NS_FORMAT_FUNCTION(2,3);

/**
 *  Initializes a client error response with the corresponding HTTP status code
 *  and an underlying NSError.
 */
- (instancetype)initWithClientError:(RSClientErrorHTTPStatusCode)errorCode underlyingError:(NSError*)underlyingError message:(NSString*)format, ... NS_FORMAT_FUNCTION(3,4);

/**
 *  Initializes a server error response with the corresponding HTTP status code
 *  and an underlying NSError.
 */
- (instancetype)initWithServerError:(RSServerErrorHTTPStatusCode)errorCode underlyingError:(NSError*)underlyingError message:(NSString*)format, ... NS_FORMAT_FUNCTION(3,4);

@end
