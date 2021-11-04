#import "RSHandler.h"

@implementation RSHandler

@synthesize matchBlock=_matchBlock;
@synthesize processBlock=_processBlock;

- (id)initWithMatchBlock:(RSMatchBlock)matchBlock
            processBlock:(RSProcessBlock)processBlock {
    if ((self = [super init])) {
        _matchBlock = matchBlock;//JF [matchBlock copy];
        _processBlock = processBlock;//JF[processBlock copy];
    }
    return self;
}

@end
