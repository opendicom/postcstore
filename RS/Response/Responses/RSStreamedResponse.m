#import "RSStreamedResponse.h"

@interface RSStreamedResponse () {
@private
  RSAsyncStreamBlock _block;
}
@end

@implementation RSStreamedResponse

+ (instancetype)responseWithContentType:(NSString*)type streamBlock:(RSStreamBlock)block {
  return [[[self class] alloc] initWithContentType:type streamBlock:block];
}

+ (instancetype)responseWithContentType:(NSString*)type asyncStreamBlock:(RSAsyncStreamBlock)block {
  return [[[self class] alloc] initWithContentType:type asyncStreamBlock:block];
}

- (instancetype)initWithContentType:(NSString*)type streamBlock:(RSStreamBlock)block {
  return [self initWithContentType:type asyncStreamBlock:^(RSBodyReaderCompletionBlock completionBlock) {
    
    NSError* error = nil;
    NSData* data = block(&error);
    completionBlock(data, error);
    
  }];
}

- (instancetype)initWithContentType:(NSString*)type asyncStreamBlock:(RSAsyncStreamBlock)block {
  if ((self = [super init])) {
    _block = [block copy];
    
    self.contentType = type;
  }
  return self;
}

- (void)asyncReadDataWithCompletion:(RSBodyReaderCompletionBlock)block {
  _block(block);
}

- (NSString*)description {
  NSMutableString* description = [NSMutableString stringWithString:[super description]];
  [description appendString:@"\n\n<STREAM>"];
  return description;
}

@end
