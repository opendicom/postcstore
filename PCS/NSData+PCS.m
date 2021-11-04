//  NSData+PCS.m



#import "NSData+PCS.h"

@implementation NSData (PCS)

static NSData *formDataPartName=nil;
static NSData *doubleQuotes=nil;
static NSData *contentType=nil;
static NSData *semicolon=nil;
static NSData *rnrn=nil;
static NSData *rn=nil;


+(NSData*)jsonpCallback:(NSString*)callback withDictionary:(NSDictionary*)dictionary
{
    NSMutableData *jsonp=[NSMutableData data];
    [jsonp appendData:[callback dataUsingEncoding:NSUTF8StringEncoding]];
    [jsonp appendData:[@"(" dataUsingEncoding:NSUTF8StringEncoding]];
    [jsonp appendData:[NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil]];
    [jsonp appendData:[@");" dataUsingEncoding:NSUTF8StringEncoding]];
    return [NSData dataWithData:jsonp];
}

+(NSData*)jsonpCallback:(NSString*)callback forDraw:(NSString*)draw withErrorString:(NSString*)error
{
    //https://datatables.net/manual/server-side#Returned-data
    return [NSData jsonpCallback:callback withDictionary:@{@"draw":draw,@"recordsTotal":@0,@"recordsFiltered":@0,@"data":@[],@"error":error}];
}


+(void)initPCS
{
    formDataPartName=[@"Content-Disposition: form-data; name=\"" dataUsingEncoding:NSASCIIStringEncoding];
    doubleQuotes=[@"\"" dataUsingEncoding:NSASCIIStringEncoding];
    contentType=[@"Content-Type: " dataUsingEncoding:NSASCIIStringEncoding];
    semicolon=[@";" dataUsingEncoding:NSASCIIStringEncoding];
    rnrn=[@"\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding];
    rn=[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding];
}

-(NSDictionary*)parseNamesValuesTypesInBodySeparatedBy:(NSData*)separator
{
    //return datatype is array,because a param name may be repeated
    
    NSMutableArray *names=[NSMutableArray array];
    NSMutableArray *values=[NSMutableArray array];
    NSMutableArray *types=[NSMutableArray array];
    //there is a separator at the beginning and at the end
    NSRange containerRange=NSMakeRange(0,self.length);
    NSRange separatorRange=[self rangeOfData:separator options:0 range:containerRange];
    NSUInteger componentStart=separatorRange.location + separatorRange.length + 2;//2...0D0A
    containerRange.location=componentStart;
    containerRange.length=self.length - componentStart;
    
    //skip 0->first separator
    separatorRange=[self rangeOfData:separator options:0 range:containerRange];
    
    while (separatorRange.location != NSNotFound)
    {
        NSMutableData *dataChunk=[NSMutableData dataWithData:[self subdataWithRange:NSMakeRange(componentStart,separatorRange.location - componentStart - 4)]];//4... 0D0A
        
        //add object to types
        NSString *type;
        NSRange contentTypeRange=[dataChunk rangeOfData:contentType options:0 range:NSMakeRange(0,[dataChunk length])];
        if (contentTypeRange.location==NSNotFound) type=@"";
        else
        {
            NSUInteger start=contentTypeRange.location+contentTypeRange.length;
            NSRange semicolonRange=[dataChunk rangeOfData:semicolon options:0 range:NSMakeRange(start,[dataChunk length]-start)];
            NSRange rnRange=[dataChunk rangeOfData:rn options:0 range:NSMakeRange(start,[dataChunk length]-start)];
            if (   semicolonRange.location==NSNotFound
                || (    rnRange.location!=NSNotFound
                    &&  rnRange.location < semicolonRange.location)
                ) type=[[NSString alloc]initWithData:[dataChunk subdataWithRange:NSMakeRange(start,rnRange.location-start)] encoding:NSUTF8StringEncoding];
            else type=[[NSString alloc]initWithData:[dataChunk subdataWithRange:NSMakeRange(start,semicolonRange.location-start)] encoding:NSUTF8StringEncoding];
        }
        [types addObject:type];
        
        //remove everything until name
        NSRange formDataPartNameRange=[dataChunk rangeOfData:formDataPartName options:0 range:NSMakeRange(0,[dataChunk length])];
        if (!formDataPartNameRange.length) break;
        [dataChunk replaceBytesInRange:NSMakeRange(0,formDataPartNameRange.location + formDataPartNameRange.length) withBytes:NULL length:0];
        
        //add object to names
        NSRange doubleQuotesRange=[dataChunk rangeOfData:doubleQuotes options:0 range:NSMakeRange(0,[dataChunk length])];
        [names addObject:[[NSString alloc]initWithData:[dataChunk subdataWithRange:NSMakeRange(0,doubleQuotesRange.location)] encoding:NSUTF8StringEncoding]];
        
        //remove everything until rnrn
        NSRange rnrnRange=[dataChunk rangeOfData:rnrn options:0 range:NSMakeRange(0,[dataChunk length])];
        [dataChunk replaceBytesInRange:NSMakeRange(0,rnrnRange.location + rnrnRange.length) withBytes:NULL length:0];

        //add object to values
        if (  ![type length]
            || [type hasPrefix:@"text"]
            || [type hasPrefix:@"application/json"]
            || [type hasPrefix:@"application/dicom+json"]
            || [type hasPrefix:@"application/xml"]
            || [type hasPrefix:@"application/xml+json"]
            )[values addObject:[[NSString alloc]initWithData:dataChunk encoding:NSUTF8StringEncoding]];
        else [values addObject:[dataChunk base64EncodedStringWithOptions:0]];
        
        componentStart=separatorRange.location + separatorRange.length + 2;//2...0D0A
        containerRange.location=componentStart;
        containerRange.length=self.length - componentStart;
        
        separatorRange=[self rangeOfData:separator options:0 range:containerRange];
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSArray arrayWithArray:names],
            @"names",
            [NSArray arrayWithArray:values],
            @"values",
            [NSArray arrayWithArray:types],
            @"types",
            nil];
}
@end
