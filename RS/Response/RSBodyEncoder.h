#import "RSResponse.h"

@class RSResponse;

@interface RSBodyEncoder : NSObject <RSBodyReader>
{
    RSResponse* __unsafe_unretained _response;
    id<RSBodyReader> __unsafe_unretained _reader;
}
- (id)initWithResponse:(RSResponse*)response reader:(id<RSBodyReader>)reader;

@end
