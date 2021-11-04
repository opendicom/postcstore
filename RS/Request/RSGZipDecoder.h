#import "RSBodyDecoder.h"
#import <zlib.h>

#define kZlibErrorDomain @"ZlibErrorDomain"
#define kGZipInitialBufferSize (256 * 1024)


@interface RSGZipDecoder : RSBodyDecoder
@end


@interface RSGZipDecoder () {
@private
    z_stream _stream;
    BOOL _finished;
}
@end
