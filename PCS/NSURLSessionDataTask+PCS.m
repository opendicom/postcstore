//
//  NSURLSessionDataTask+PCS.m

//
//  Created by jacquesfauquex on 2017129.
//  Copyright © 2017 ridi.salud.uy. All rights reserved.
//

#import "NSURLSessionDataTask+PCS.h"

@implementation NSURLSessionDataTask (PCS)

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse *__autoreleasing *)responsePointer error:(NSError *__autoreleasing *)errorPointer
{
    dispatch_semaphore_t semaphore;
    __block NSData *result = nil;
    
    semaphore = dispatch_semaphore_create(0);
    
    void (^completionHandler)(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error);
    completionHandler = ^(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error)
    {
        if ( errorPointer != NULL )
        {
            *errorPointer = error;
        }
        
        if ( responsePointer != NULL )
        {
            *responsePointer = response;
        }
        
        if ( error == nil )
        {
            result = data;
        }
        
        dispatch_semaphore_signal(semaphore);
    };
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:completionHandler] resume];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return result;
}
@end
