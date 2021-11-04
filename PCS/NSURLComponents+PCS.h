//  NSURLComponents+PCS.h


#import <Foundation/Foundation.h>

@interface NSURLComponents (PCS)

//generic

+(void)initializeStaticRegex;

-(NSInteger)nextQueryItemsIndexForPredicateString:(NSString*)predicateString key:(NSString*)key value:(NSString*)value startIndex:(NSInteger)startIndex;

-(NSString*)firstQueryItemNamed:(NSString*)name;

-(NSString*)queryWithoutItemNamed:(NSString*)name;

//wado
-(NSString*)wadoDicomQueryItemsError;

@end
