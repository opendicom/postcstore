#import "NSString+httpHeader.h"
#import <netdb.h>
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (httpHeader)


+(NSString*)stringFromSockAddr:(const struct sockaddr*)addr includeService:(BOOL)includeService
{
    NSString* string = nil;
    char hostBuffer[NI_MAXHOST];
    char serviceBuffer[NI_MAXSERV];
    if (getnameinfo(addr, addr->sa_len, hostBuffer, sizeof(hostBuffer), serviceBuffer, sizeof(serviceBuffer), NI_NUMERICHOST | NI_NUMERICSERV | NI_NOFQDN) >= 0) {
        string = includeService ? [NSString stringWithFormat:@"%s:%s", hostBuffer, serviceBuffer] : [NSString stringWithUTF8String:hostBuffer];
    }
    return string;
}

-(NSString*)normalizeHeaderValue
{

    NSRange range = [self rangeOfString:@";"];
    // Assume part before ";" separator is case-insensitive
    if (range.location != NSNotFound)
    {
        return [[[self substringToIndex:range.location] lowercaseString] stringByAppendingString:[self substringFromIndex:range.location]];
    }
    return [self lowercaseString];
}


-(NSString*)valueForName:(NSString*)name
{
    NSString* parameter = nil;
    NSScanner* scanner = [[NSScanner alloc] initWithString:self];
    [scanner setCaseSensitive:NO];
    // Assume parameter names are case-insensitive
    NSString* string = [NSString stringWithFormat:@"%@=", name];
    if ([scanner scanUpToString:string intoString:NULL])
    {
        [scanner scanString:string intoString:NULL];
        if ([scanner scanString:@"\"" intoString:NULL]) {
            [scanner scanUpToString:@"\"" intoString:&parameter];
        } else {
            [scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&parameter];
        }
    }
    return parameter;
}

@end


