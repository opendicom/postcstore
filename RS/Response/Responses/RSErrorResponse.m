#import "RSErrorResponse.h"

@interface RSErrorResponse ()
- (instancetype)initWithStatusCode:(NSInteger)statusCode underlyingError:(NSError*)underlyingError messageFormat:(NSString*)format arguments:(va_list)arguments;
@end

@implementation RSErrorResponse

+ (instancetype)responseWithClientError:(RSClientErrorHTTPStatusCode)errorCode message:(NSString*)format, ... {
  va_list arguments;
  va_start(arguments, format);
  RSErrorResponse* response = [[self alloc] initWithStatusCode:errorCode underlyingError:nil messageFormat:format arguments:arguments];
  va_end(arguments);
  return response;
}

+ (instancetype)responseWithServerError:(RSServerErrorHTTPStatusCode)errorCode message:(NSString*)format, ... {
  va_list arguments;
  va_start(arguments, format);
  RSErrorResponse* response = [[self alloc] initWithStatusCode:errorCode underlyingError:nil messageFormat:format arguments:arguments];
  va_end(arguments);
  return response;
}

+ (instancetype)responseWithClientError:(RSClientErrorHTTPStatusCode)errorCode underlyingError:(NSError*)underlyingError message:(NSString*)format, ... {
  va_list arguments;
  va_start(arguments, format);
  RSErrorResponse* response = [[self alloc] initWithStatusCode:errorCode underlyingError:underlyingError messageFormat:format arguments:arguments];
  va_end(arguments);
  return response;
}

+ (instancetype)responseWithServerError:(RSServerErrorHTTPStatusCode)errorCode underlyingError:(NSError*)underlyingError message:(NSString*)format, ... {
  va_list arguments;
  va_start(arguments, format);
  RSErrorResponse* response = [[self alloc] initWithStatusCode:errorCode underlyingError:underlyingError messageFormat:format arguments:arguments];
  va_end(arguments);
  return response;
}

static inline NSString* _EscapeHTMLString(NSString* string) {
  return [string stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
}

- (instancetype)initWithStatusCode:(NSInteger)statusCode underlyingError:(NSError*)underlyingError messageFormat:(NSString*)format arguments:(va_list)arguments {
  NSString* message = [[NSString alloc] initWithFormat:format arguments:arguments];
  NSString* title = [NSString stringWithFormat:@"HTTP Error %i", (int)statusCode];
  NSString* error = underlyingError ? [NSString stringWithFormat:@"[%@] %@ (%li)", underlyingError.domain, _EscapeHTMLString(underlyingError.localizedDescription), (long)underlyingError.code] : @"";
  NSString* html = [NSString stringWithFormat:@"<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\"><title>%@</title></head><body><h1>%@: %@</h1><h3>%@</h3></body></html>",
                                              title, title, _EscapeHTMLString(message), error];
  if ((self = [self initWithHTML:html])) {
    self.statusCode = statusCode;
  }
  return self;
}

- (instancetype)initWithClientError:(RSClientErrorHTTPStatusCode)errorCode message:(NSString*)format, ... {
  va_list arguments;
  va_start(arguments, format);
  self = [self initWithStatusCode:errorCode underlyingError:nil messageFormat:format arguments:arguments];
  va_end(arguments);
  return self;
}

- (instancetype)initWithServerError:(RSServerErrorHTTPStatusCode)errorCode message:(NSString*)format, ... {
  va_list arguments;
  va_start(arguments, format);
  self = [self initWithStatusCode:errorCode underlyingError:nil messageFormat:format arguments:arguments];
  va_end(arguments);
  return self;
}

- (instancetype)initWithClientError:(RSClientErrorHTTPStatusCode)errorCode underlyingError:(NSError*)underlyingError message:(NSString*)format, ... {
  va_list arguments;
  va_start(arguments, format);
  self = [self initWithStatusCode:errorCode underlyingError:underlyingError messageFormat:format arguments:arguments];
  va_end(arguments);
  return self;
}

- (instancetype)initWithServerError:(RSServerErrorHTTPStatusCode)errorCode underlyingError:(NSError*)underlyingError message:(NSString*)format, ... {
  va_list arguments;
  va_start(arguments, format);
  self = [self initWithStatusCode:errorCode underlyingError:underlyingError messageFormat:format arguments:arguments];
  va_end(arguments);
  return self;
}

@end
