#import <Foundation/Foundation.h>

@interface NSString (httpHeader)

+(NSString*)stringFromSockAddr:(const struct sockaddr*)addr includeService:(BOOL)includeService;
-(NSString*)normalizeHeaderValue;
-(NSString*)valueForName:(NSString*)name;

@end
