#import "RSRequest.h"
#import "RSGZipDecoder.h"
#import "RFC822.h"
#import "NSString+httpHeader.h"
#import "printfLog.h"

NSString* GCDWebServerUnescapeURLString(NSString* string) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)string, CFSTR(""), kCFStringEncodingUTF8));
#pragma clang diagnostic pop
}

// http://www.w3schools.com/tags/ref_charactersets.asp
NSStringEncoding GCDWebServerStringEncodingFromCharset(NSString* charset) {
    NSStringEncoding encoding = kCFStringEncodingInvalidId;
    if (charset) {
        encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)charset));
    }
    return (encoding != kCFStringEncodingInvalidId ? encoding : NSUTF8StringEncoding);
}


BOOL GCDWebServerIsTextContentType(NSString* type) {
    return ([type hasPrefix:@"text/"] || [type hasPrefix:@"application/json"] || [type hasPrefix:@"application/xml"]);
}

NSString* GCDWebServerDescribeData(NSData* data, NSString* type) {
    if (GCDWebServerIsTextContentType(type)) {
        NSString* charset = [type valueForName:@"charset"];
        NSString* string = [[NSString alloc] initWithData:data encoding:GCDWebServerStringEncodingFromCharset(charset)];
        if (string) {
            return string;
        }
    }
    return [NSString stringWithFormat:@"<%lu bytes>", (unsigned long)data.length];
}


NSString* GCDWebServerTruncateHeaderValue(NSString* value) {
    if (value) {
        NSRange range = [value rangeOfString:@";"];
        if (range.location != NSNotFound) {
            return [value substringToIndex:range.location];
        }
    }
    return value;
}


NSDictionary* GCDWebServerParseURLEncodedForm(NSString* form) {
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    NSScanner* scanner = [[NSScanner alloc] initWithString:form];
    [scanner setCharactersToBeSkipped:nil];
    while (1) {
        NSString* key = nil;
        if (![scanner scanUpToString:@"=" intoString:&key] || [scanner isAtEnd]) {
            break;
        }
        [scanner setScanLocation:([scanner scanLocation] + 1)];
        
        NSString* value = nil;
        [scanner scanUpToString:@"&" intoString:&value];
        if (value == nil) {
            value = @"";
        }
        
        key = [key stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        NSString* unescapedKey = key ? GCDWebServerUnescapeURLString(key) : nil;
        value = [value stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        NSString* unescapedValue = value ? GCDWebServerUnescapeURLString(value) : nil;
        if (unescapedKey && unescapedValue) {
            [parameters setObject:unescapedValue forKey:unescapedKey];
        } else {
            printfLog(@"Failed parsing URL encoded form for key \"%@\" and value \"%@\"", key, value);
        }
        
        if ([scanner isAtEnd]) {
            break;
        }
        [scanner setScanLocation:([scanner scanLocation] + 1)];
    }
    return parameters;
}


//
@interface RSRequest ()
@property(nonatomic) NSMutableData* data;
@end


@implementation RSRequest : NSObject


@synthesize method=_method;
@synthesize URL=_url;
@synthesize headers=_headers;
@synthesize path=_path;
@synthesize query=_query;
@synthesize contentType=_type;
@synthesize contentLength=_length;
@synthesize ifModifiedSince=_modifiedSince;
@synthesize ifNoneMatch=_noneMatch;
@synthesize byteRange=_range;
@synthesize acceptsGzipContentEncoding=_gzipAccepted;
@synthesize usesChunkedTransferEncoding=_chunked;
@synthesize localAddressString=_localAddressString;
@synthesize remoteAddressString=_remoteAddressString;
@synthesize socket=_socket;

- (instancetype)initWithMethod:(NSString*)method
                           url:(NSURL*)url
                       headers:(NSDictionary*)headers
                          path:(NSString*)path
                         query:(NSDictionary*)query
                         local:(NSString*)localAddressString
                        remote:(NSString*)remoteAddressString
                        socket:(int)socket;
{
  if ((self = [super init])) {
    _method = [method copy];
    _url = url;
    _headers = headers;
    _path = [path copy];
    _query = query;
    _localAddressString = localAddressString;
    _remoteAddressString = remoteAddressString;
    _socket=socket;
      
    _type = [[_headers objectForKey:@"Content-Type"] normalizeHeaderValue];
    _chunked = [[[_headers objectForKey:@"Transfer-Encoding"] normalizeHeaderValue] isEqualToString:@"chunked"];
    NSString* lengthHeader = [_headers objectForKey:@"Content-Length"];
    if (lengthHeader) {
      NSInteger length = [lengthHeader integerValue];
      if (_chunked || (length < 0)) {
        printfLog(@"Invalid 'Content-Length' header '%@' for '%@' request on \"%@\"", lengthHeader, _method, _url);
        return nil;
      }
      _length = length;
      if (_type == nil) {
        _type = @"application/octet-stream";
      }
    } else if (_chunked) {
      if (_type == nil) {
        _type = @"application/octet-stream";
      }
      _length = NSUIntegerMax;
    } else {
      if (_type) {
        printfLog(@"Ignoring 'Content-Type' header for '%@' request on \"%@\"", _method, _url);
        _type = nil;  // Content-Type without Content-Length or chunked-encoding doesn't make sense
      }
      _length = NSUIntegerMax;
    }
    
    NSString* modifiedHeader = [_headers objectForKey:@"If-Modified-Since"];
    if (modifiedHeader) _modifiedSince = [[RFC822 dateFromString:modifiedHeader] copy];
    _noneMatch = [_headers objectForKey:@"If-None-Match"];
    
    _range = NSMakeRange(NSUIntegerMax, 0);
    NSString* rangeHeader = [[_headers objectForKey:@"Range"] normalizeHeaderValue];
    if (rangeHeader) {
      if ([rangeHeader hasPrefix:@"bytes="]) {
        NSArray* components = [[rangeHeader substringFromIndex:6] componentsSeparatedByString:@","];
        if (components.count == 1) {
          components = [[components firstObject] componentsSeparatedByString:@"-"];
          if (components.count == 2) {
            NSString* startString = [components objectAtIndex:0];
            NSInteger startValue = [startString integerValue];
            NSString* endString = [components objectAtIndex:1];
            NSInteger endValue = [endString integerValue];
            if (startString.length && (startValue >= 0) && endString.length && (endValue >= startValue)) {  // The second 500 bytes: "500-999"
              _range.location = startValue;
              _range.length = endValue - startValue + 1;
            } else if (startString.length && (startValue >= 0)) {  // The bytes after 9500 bytes: "9500-"
              _range.location = startValue;
              _range.length = NSUIntegerMax;
            } else if (endString.length && (endValue > 0)) {  // The final 500 bytes: "-500"
              _range.location = NSUIntegerMax;
              _range.length = endValue;
            }
          }
        }
      }
      if ((_range.location == NSUIntegerMax) && (_range.length == 0)) {  // Ignore "Range" header if syntactically invalid
        printfLog(@"Failed to parse 'Range' header \"%@\" for url: %@", rangeHeader, url);
      }
    }
    
    if ([[_headers objectForKey:@"Accept-Encoding"] rangeOfString:@"gzip"].location != NSNotFound) {
      _gzipAccepted = YES;
    }
    
    _decoders = [[NSMutableArray alloc] init];
    _attributes = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (BOOL)hasBody {
  return _type ? YES : NO;
}

- (BOOL)hasByteRange {
  return ((_range.location != NSUIntegerMax) || (_range.length > 0));
}

- (id)attributeForKey:(NSString*)key {
  return [_attributes objectForKey:key];
}

/*
- (BOOL)open:(NSError**)error {
  return YES;
}

- (BOOL)writeData:(NSData*)data error:(NSError**)error {
  return YES;
}

- (BOOL)close:(NSError**)error {
  return YES;
}
*/

- (void)prepareForWriting {
  _writer = self;
  if ([[[self.headers objectForKey:@"Content-Encoding"] normalizeHeaderValue] isEqualToString:@"gzip"]) {
    RSGZipDecoder* decoder = [[RSGZipDecoder alloc] initWithRequest:self writer:_writer];
    [_decoders addObject:decoder];
    _writer = decoder;
  }
}

- (BOOL)performOpen:(NSError**)error {
  if (_opened) {
    return NO;
  }
  _opened = YES;
  return [_writer open:error];
}

- (BOOL)performWriteData:(NSData*)data error:(NSError**)error {
  return [_writer writeData:data error:error];
}

- (BOOL)performClose:(NSError**)error {
  return [_writer close:error];
}

- (void)setAttribute:(id)attribute forKey:(NSString*)key {
  [_attributes setValue:attribute forKey:key];
}
/*
- (NSString*)localAddressString {
    return _localAddressString;
}

- (NSString*)remoteAddressString {
    return _localAddressString;
}
*/

/*
- (NSString*)description {
  NSMutableString* description = [NSMutableString stringWithFormat:@"%@ %@", _method, _path];
  for (NSString* argument in [[_query allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
    [description appendFormat:@"\n  %@ = %@", argument, [_query objectForKey:argument]];
  }
  [description appendString:@"\n"];
  for (NSString* header in [[_headers allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
    [description appendFormat:@"\n%@: %@", header, [_headers objectForKey:header]];
  }
  return description;
}
*/
//data
- (BOOL)open:(NSError**)error {
    if (self.contentLength != NSUIntegerMax) {
        _data = [[NSMutableData alloc] initWithCapacity:self.contentLength];
    } else {
        _data = [[NSMutableData alloc] init];
    }
    if (_data == nil) {
        if (error) {
            *error = [NSError errorWithDomain:@"GCDWebServerErrorDomain" code:-1 userInfo:@{ NSLocalizedDescriptionKey : @"Failed allocating memory" }];
        }
        return NO;
    }
    return YES;
}

- (BOOL)writeData:(NSData*)data error:(NSError**)error {
    [_data appendData:data];
    return YES;
}

- (BOOL)close:(NSError**)error {
    
    NSString* charset = [self.contentType valueForName:@"charset"];
    
    if (charset)
    {
       NSString* string = [[NSString alloc] initWithData:self.data encoding:GCDWebServerStringEncodingFromCharset(charset)];
    
       _arguments = GCDWebServerParseURLEncodedForm(string);
    }
    return YES;
}

- (NSString*)description {
    NSMutableString* description = [NSMutableString stringWithFormat:@"%@ %@", _method, _path];
    for (NSString* argument in [[_query allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
        [description appendFormat:@"\n  %@ = %@", argument, [_query objectForKey:argument]];
    }
    [description appendString:@"\n"];
    for (NSString* header in [[_headers allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
        [description appendFormat:@"\n%@: %@", header, [_headers objectForKey:header]];
    }
    if (_data) {
        [description appendString:@"\n\n"];
        [description appendString:GCDWebServerDescribeData(_data, (NSString*)self.contentType)];
    }
    for (NSString* argument in [[_arguments allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
        [description appendFormat:@"\n%@ = %@", argument, [_arguments objectForKey:argument]];
    }

    return description;
}


- (NSString*)text {
    if (_text == nil) {
        if ([self.contentType hasPrefix:@"text/"]) {
            NSString* charset = [self.contentType valueForName:@"charset"];
            _text = [[NSString alloc] initWithData:self.data encoding:GCDWebServerStringEncodingFromCharset(charset)];
        } else {
            printfLog(@"can not extract text if content type does not start with text/");
        }
    }
    return _text;
}

- (id)jsonObject {
    if (_jsonObject == nil) {
        NSString* mimeType = GCDWebServerTruncateHeaderValue(self.contentType);
        if ([mimeType isEqualToString:@"application/json"] || [mimeType isEqualToString:@"text/json"] || [mimeType isEqualToString:@"text/javascript"]) {
            _jsonObject = [NSJSONSerialization JSONObjectWithData:_data options:0 error:NULL];
        } else {
            printfLog(@"Content-Type \"%@\" is not correct for json content", self.contentType);
        }
    }
    return _jsonObject;
}

@end
