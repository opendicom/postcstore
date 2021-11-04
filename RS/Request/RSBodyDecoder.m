#import "RSBodyDecoder.h"

@implementation RSBodyDecoder

- (id)initWithRequest:(RSRequest*)request writer:(id<RSBodyWriter>)writer {
    if ((self = [super init])) {
        _request = request;
        _writer = writer;
    }
    return self;
}

- (BOOL)open:(NSError**)error {
    return [_writer open:error];
}

- (BOOL)writeData:(NSData*)data error:(NSError**)error {
    return [_writer writeData:data error:error];
}

- (BOOL)close:(NSError**)error {
    return [_writer close:error];
}

@end
