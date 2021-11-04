#import "RSBodyEncoder.h"
#import <zlib.h>

@interface RSGZipEncoder : RSBodyEncoder
{
    z_stream _stream;
    BOOL _finished;
}
@end
