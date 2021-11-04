#import "RSResponse.h"
#import "RSGZipEncoder.h"

@implementation RSResponse

@synthesize contentType=_type;
@synthesize contentLength=_length;
@synthesize statusCode=_status;
@synthesize cacheControlMaxAge=_maxAge;
@synthesize lastModifiedDate=_lastModified;
@synthesize eTag=_eTag;
@synthesize gzipContentEncodingEnabled=_gzipped;
@synthesize additionalHeaders=_headers;

+ (instancetype)response {
  return [[[self class] alloc] init];
}

- (instancetype)init {
  if ((self = [super init])) {
    _type = nil;
    _length = NSUIntegerMax;
    _status = 200;//OK
    _maxAge = 0;
    _headers = [[NSMutableDictionary alloc] init];
    _encoders = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)setValue:(NSString*)value forAdditionalHeader:(NSString*)header {
  [_headers setValue:value forKey:header];
}

- (BOOL)hasBody {
  return _type ? YES : NO;
}

- (BOOL)usesChunkedTransferEncoding {
  return (_type != nil) && (_length == NSUIntegerMax);
}

- (BOOL)open:(NSError**)error {
  return YES;
}

- (NSData*)readData:(NSError**)error {
  return [NSData data];
}

- (void)close {
  ;
}

- (void)prepareForReading {
  _reader = self;
  if (_gzipped) {
    RSGZipEncoder* encoder = [[RSGZipEncoder alloc] initWithResponse:self reader:_reader];
    [_encoders addObject:encoder];
    _reader = encoder;
  }
}

- (BOOL)performOpen:(NSError**)error {
  if (_opened) {
    return NO;
  }
  _opened = YES;
  return [_reader open:error];
}

- (void)performReadDataWithCompletion:(RSBodyReaderCompletionBlock)block {
  if ([_reader respondsToSelector:@selector(asyncReadDataWithCompletion:)]) {
    [_reader asyncReadDataWithCompletion:[block copy]];
  } else {
    NSError* error = nil;
    NSData* data = [_reader readData:&error];
    block(data, error);
  }
}

- (void)performClose {
  [_reader close];
}

- (NSString*)description {
  NSMutableString* description = [NSMutableString stringWithFormat:@"Status Code = %i", (int)_status];
  if (_type) {
    [description appendFormat:@"\nContent Type = %@", _type];
  }
  if (_length != NSUIntegerMax) {
    [description appendFormat:@"\nContent Length = %lu", (unsigned long)_length];
  }
  [description appendFormat:@"\nCache Control Max Age = %lu", (unsigned long)_maxAge];
  if (_lastModified) {
    [description appendFormat:@"\nLast Modified Date = %@", _lastModified];
  }
  if (_eTag) {
    [description appendFormat:@"\nETag = %@", _eTag];
  }
  if (_headers.count) {
    [description appendString:@"\n"];
    for (NSString* header in [[_headers allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
      [description appendFormat:@"\n%@: %@", header, [_headers objectForKey:header]];
    }
  }
  return description;
}

+ (instancetype)responseWithStatusCode:(NSInteger)statusCode {
  return [[self alloc] initWithStatusCode:statusCode];
}

+ (instancetype)responseWithRedirect:(NSURL*)location permanent:(BOOL)permanent {
  return [[self alloc] initWithRedirect:location permanent:permanent];
}

- (instancetype)initWithStatusCode:(NSInteger)statusCode {
  if ((self = [self init])) {
    self.statusCode = statusCode;
  }
  return self;
}

- (instancetype)initWithRedirect:(NSURL*)location permanent:(BOOL)permanent {
  if ((self = [self init])) {
    self.statusCode = permanent ? 301 : 307;//?MovedPermanently:TemporaryRedirect
    [self setValue:[location absoluteString] forAdditionalHeader:@"Location"];
  }
  return self;
}

@end
