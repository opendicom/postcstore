#import "RSRequest.h"

@class RSRequest;

@interface RSBodyDecoder : NSObject <RSBodyWriter>
{
    RSRequest* __unsafe_unretained _request;
    id<RSBodyWriter> __unsafe_unretained _writer;
}
- (id)initWithRequest:(RSRequest*)request writer:(id<RSBodyWriter>)writer;
@end
