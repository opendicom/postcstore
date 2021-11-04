//  NSData+PCS.h

#import <Foundation/Foundation.h>


@interface NSData (PCS)
+(NSData*)jsonpCallback:(NSString*)callback withDictionary:(NSDictionary*)dictionary;
+(NSData*)jsonpCallback:(NSString*)callback forDraw:(NSString*)draw withErrorString:(NSString*)error;


+(void)initPCS;
-(NSDictionary*)parseNamesValuesTypesInBodySeparatedBy:(NSData*)separator;

@end
