//
//  NSURLSessionDataTask+PCS.h

//
//  Created by jacquesfauquex on 2017129.
//  Copyright © 2017 ridi.salud.uy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSessionDataTask (PCS)

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error;

@end
