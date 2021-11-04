#import "RSGZipDecoder.h"

#define kZlibErrorDomain @"ZlibErrorDomain"
#define kGZipInitialBufferSize (256 * 1024)

@implementation RSGZipDecoder

- (BOOL)open:(NSError**)error {
    int result = inflateInit2(&_stream, 15 + 16);
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

- (BOOL)writeData:(NSData*)data error:(NSError**)error {
    _stream.next_in = (Bytef*)data.bytes;
    _stream.avail_in = (uInt)data.length;
    NSMutableData* decodedData = [[NSMutableData alloc] initWithLength:kGZipInitialBufferSize];
    if (decodedData == nil) {
        return NO;
    }
    NSUInteger length = 0;
    while (1) {
        NSUInteger maxLength = decodedData.length - length;
        _stream.next_out = (Bytef*)((char*)decodedData.mutableBytes + length);
        _stream.avail_out = (uInt)maxLength;
        int result = inflate(&_stream, Z_NO_FLUSH);
        if ((result != Z_OK) && (result != Z_STREAM_END)) {
            if (error) {
                *error = [NSError errorWithDomain:kZlibErrorDomain code:result userInfo:nil];
            }
            return NO;
        }
        length += maxLength - _stream.avail_out;
        if (_stream.avail_out > 0) {
            if (result == Z_STREAM_END) {
                _finished = YES;
            }
            break;
        }
        decodedData.length = 2 * decodedData.length;  // zlib has used all the output buffer so resize it and try again in case more data is available
    }
    decodedData.length = length;
    BOOL success = length ? [super writeData:decodedData error:error] : YES;  // No need to call writer if we have no data yet
    return success;
}

- (BOOL)close:(NSError**)error {
    inflateEnd(&_stream);
    return [super close:error];
}

@end
