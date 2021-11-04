#import "RSDataResponse.h"


@interface RSDataResponse () {
@private
  NSData* _data;
  BOOL _done;
}
@end

@implementation RSDataResponse

+ (instancetype)responseWithData:(NSData*)data contentType:(NSString*)type {
  return [[[self class] alloc] initWithData:data contentType:type];
}

- (instancetype)initWithData:(NSData*)data contentType:(NSString*)type {
  if (data == nil) {
    return nil;
  }
  
  if ((self = [super init])) {
    _data = data;
    
    self.contentType = type;
    self.contentLength = data.length;
  }
  return self;
}

- (NSData*)readData:(NSError**)error {
  NSData* data;
  if (_done) {
    data = [NSData data];
  } else {
    data = _data;
    _done = YES;
  }
  return data;
}

- (NSString*)description {
  NSMutableString* description = [NSMutableString stringWithString:[super description]];
  [description appendString:@"\n\n"];
    
    if (
           [self.contentType hasPrefix:@"text/"]
        || [self.contentType hasPrefix:@"application/json"]
        || [self.contentType hasPrefix:@"application/xml"]
        ) {
        
        NSString* charset = nil;
        NSScanner* scanner = [[NSScanner alloc] initWithString:self.contentType];
        [scanner setCaseSensitive:NO];  // Assume parameter names are case-insensitive
        if ([scanner scanUpToString:@"charset=" intoString:NULL]) {
            [scanner scanString:@"charset=" intoString:NULL];
            if ([scanner scanString:@"\"" intoString:NULL]) {
                [scanner scanUpToString:@"\"" intoString:&charset];
            } else {
                [scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&charset];
            }
        }
        
        
        // http://www.w3schools.com/tags/ref_charactersets.asp
        NSStringEncoding encoding = kCFStringEncodingInvalidId;
        if (charset) encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)charset));

        NSString* string = nil;
        if (encoding != kCFStringEncodingInvalidId)
            string = [[NSString alloc] initWithData:_data encoding:encoding];
        else
            string = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
        
        if (string) [description appendString:string];
        else        [description appendFormat:@"<%lu bytes>", (unsigned long)_data.length];
    }
  return description;
}

@end

@implementation RSDataResponse (Extensions)

+ (instancetype)responseWithText:(NSString*)text {
  return [[self alloc] initWithText:text];
}

+ (instancetype)responseWithHTML:(NSString*)html {
  return [[self alloc] initWithHTML:html];
}

+ (instancetype)responseWithHTMLTemplate:(NSString*)path variables:(NSDictionary*)variables {
  return [[self alloc] initWithHTMLTemplate:path variables:variables];
}

+ (instancetype)responseWithJSONObject:(id)object {
  return [[self alloc] initWithJSONObject:object];
}

+ (instancetype)responseWithJSONObject:(id)object contentType:(NSString*)type {
  return [[self alloc] initWithJSONObject:object contentType:type];
}

- (instancetype)initWithText:(NSString*)text {
  NSData* data = [text dataUsingEncoding:NSUTF8StringEncoding];
  if (data == nil) {
    return nil;
  }
  return [self initWithData:data contentType:@"text/plain; charset=utf-8"];
}

- (instancetype)initWithHTML:(NSString*)html {
  NSData* data = [html dataUsingEncoding:NSUTF8StringEncoding];
  if (data == nil) {
    return nil;
  }
  return [self initWithData:data contentType:@"text/html; charset=utf-8"];
}

- (instancetype)initWithHTMLTemplate:(NSString*)path variables:(NSDictionary*)variables {
  NSMutableString* html = [[NSMutableString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
  [variables enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* value, BOOL* stop) {
    [html replaceOccurrencesOfString:[NSString stringWithFormat:@"%%%@%%", key] withString:value options:0 range:NSMakeRange(0, html.length)];
  }];
  id response = [self initWithHTML:html];
  return response;
}

- (instancetype)initWithJSONObject:(id)object {
  return [self initWithJSONObject:object contentType:@"application/json"];
}

- (instancetype)initWithJSONObject:(id)object contentType:(NSString*)type {
  NSData* data = [NSJSONSerialization dataWithJSONObject:object options:0 error:NULL];
  if (data == nil) {
    return nil;
  }
  return [self initWithData:data contentType:type];
}

@end
