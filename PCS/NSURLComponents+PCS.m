//  NSURLComponents+PCS.m



#import "NSURLComponents+PCS.h"

static NSRegularExpression *UIRegex;
static NSRegularExpression *SHRegex;

@implementation NSURLComponents (PCS)

//generic
+ (void)initializeStaticRegex
{
    UIRegex = [NSRegularExpression regularExpressionWithPattern:@"^[1-2](\\d)*(\\.0|\\.[1-9](\\d)*)*$" options:0 error:NULL];
    SHRegex = [NSRegularExpression regularExpressionWithPattern:@"^(?:\\s*)([^\\r\\n\\f\\t]*[^\\r\\n\\f\\t\\s])(?:\\s*)$" options:0 error:NULL];
}

-(NSInteger)nextQueryItemsIndexForPredicateString:(NSString*)predicateString key:(NSString*)key value:(NSString*)value startIndex:(NSInteger)startIndex
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString,key,value];
    if (startIndex < 0) return NSNotFound;
    while (startIndex < [self.queryItems count]) {
        if ([predicate evaluateWithObject:self.queryItems[startIndex]]) return startIndex;
        startIndex++;
    }
    return NSNotFound;
}

-(NSString*)firstQueryItemNamed:(NSString*)name
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K=%@",@"name",name];
    for (NSURLQueryItem *item in self.queryItems)
    {
        if ([predicate evaluateWithObject:item]) return item.value;
    }
    return nil;
}

-(NSString*)queryWithoutItemNamed:(NSString*)name
{
    NSMutableString *q=[NSMutableString string];
    NSUInteger c=[self.queryItems count];
    if (c==0)return @"";
    for (int i=0; i<[self.queryItems count];i++)
    {
        if (![self.queryItems[i].name isEqualToString:name])[q appendFormat:@"%@=%@&",self.queryItems[i].name,self.queryItems[i].value];
    }
    [q deleteCharactersInRange:NSMakeRange([q length]-1,1)];
    return [NSString stringWithString:q];
}

//wado
-(NSString*)wadoDicomQueryItemsError
{
    //?requestType=WADO
    //&contentType=application/dicom
    //&studyUID={studyUID}
    //&seriesUID={seriesUID}
    //&objectUID={objectUID}

    //uses first occurrence only
    
    BOOL requestType=false;
    BOOL contentType=false;
    BOOL studyUID=false;
    BOOL seriesUID=false;
    BOOL objectUID=false;
    
    for (NSURLQueryItem* i in self.queryItems)
    {
        if (!requestType && [i.name isEqualToString:@"requestType"] && [i.value isEqualToString:@"WADO"]) requestType=true;
        else if (!contentType && [i.name isEqualToString:@"contentType"] && [i.value isEqualToString:@"application/dicom"]) contentType=true;
        else if (!studyUID && [i.name isEqualToString:@"studyUID"] && [UIRegex numberOfMatchesInString:i.value options:0 range:NSMakeRange(0,[i.value length])]) studyUID=true;
        else if (!seriesUID && [i.name isEqualToString:@"seriesUID"] && [UIRegex numberOfMatchesInString:i.value options:0 range:NSMakeRange(0,[i.value length])]) seriesUID=true;
        else if (!objectUID && [i.name isEqualToString:@"objectUID"] && [UIRegex numberOfMatchesInString:i.value options:0 range:NSMakeRange(0,[i.value length])]) objectUID=true;
    }
    if (requestType && contentType && studyUID && seriesUID && objectUID) return nil;
    if (contentType==false) return @"contentType";
    if (studyUID==false) return @"studyUID";
    if (seriesUID==false) return @"seriesUID";
    if (objectUID==false) return @"objectUID";
    return @"error";
}

@end
