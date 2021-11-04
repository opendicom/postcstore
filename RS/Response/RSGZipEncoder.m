#import "RSGZipEncoder.h"

#define kZlibErrorDomain @"ZlibErrorDomain"
#define kGZipInitialBufferSize (256 * 1024)

@implementation RSGZipEncoder

- (id)initWithResponse:(RSResponse*)response reader:(id<RSBodyReader>)reader {
    if ((self = [super initWithResponse:response reader:reader])) {
        response.contentLength = NSUIntegerMax;  // Make sure "Content-Length" header is not set since we don't know it
        [response setValue:@"gzip" forAdditionalHeader:@"Content-Encoding"];
    }
    return self;
}

- (BOOL)open:(NSError**)error {
    int result = deflateInit2(&_stream, Z_DEFAULT_COMPRESSION, Z_DEFLATED, 15 + 16, 8, Z_DEFAULT_STRATEGY);
    if (result != Z_OK) {
        if (error) {
            *error = [NSError errorWithDomain:kZlibErrorDomain code:result userInfo:nil];
        }
        return NO;
    }
    if (![super open:error]) {
        deflateEnd(&_stream);
        return NO;
    }
    return YES;
}

- (NSData*)readData:(NSError**)error {
    NSMutableData* encodedData;
    if (_finished) {
        encodedData = [[NSMutableData alloc] init];
    } else {
        encodedData = [[NSMutableData alloc] initWithLength:kGZipInitialBufferSize];
        if (encodedData == nil) {
            return nil;
        }
        NSUInteger length = 0;
        do {
            NSData* data = [super readData:error];
            if (data == nil) {
                return nil;
            }
            _stream.next_in = (Bytef*)data.bytes;
            _stream.avail_in = (uInt)data.length;
            while (1) {
                NSUInteger maxLength = encodedData.length - length;
                _stream.next_out = (Bytef*)((char*)encodedData.mutableBytes + length);
                _stream.avail_out = (uInt)maxLength;
                int result = deflate(&_stream, data.length ? Z_NO_FLUSH : Z_FINISH);
                if (result == Z_STREAM_END) {
                    _finished = YES;
                } else if (result != Z_OK) {
                    if (error) {
                        *error = [NSError errorWithDomain:kZlibErrorDomain code:result userInfo:nil];
                    }
                    return nil;
                }
                length += maxLength - _stream.avail_out;
                if (_stream.avail_out > 0) {
                    break;
                }
                encodedData.length = 2 * encodedData.length;  // zlib has used all the output buffer so resize it and try again in case more data is available
            }
        } while (length == 0);  // Make sure we don't return an empty NSData if not in finished state
        encodedData.length = length;
    }
    return encodedData;
}

- (void)close {
    deflateEnd(&_stream);
    [super close];
}

@end
