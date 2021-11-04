#import "RSHandler.h"

/**
 *  The RS class listens for incoming HTTP requests on a given port,
 *  then passes each one to a "handler" capable of generating an HTTP response
 *  for it, which is then sent back to the client.
 *
 *  RS instances can be created and used from any thread but it's
 *  recommended to have the main thread's runloop be running
 */
@interface RS : NSObject
{
    dispatch_queue_t _syncQueue;
    dispatch_group_t _sourceGroup;
    NSMutableArray* _handlers;
    dispatch_source_t _source4;
    dispatch_source_t _source6;
}

@property(nonatomic, readonly) NSArray* handlers;

- (instancetype)init;

- (void)addHandler:(NSString*)method
              path:(NSString*)path
      processBlock:(RSProcessBlock)processBlock;

- (void)addHandler:(NSString*)method
             regex:(NSRegularExpression*)regex
      processBlock:(RSProcessBlock)processBlock;

- (BOOL)startWithPort:(NSUInteger)port maxPendingConnections:(NSUInteger)maxPendingConnections error:(NSError**)error;

@end

