//
//  NSMutableDictionary+DICM.m
//  FoundationDICM2
//
//  Created by jacques on 20100824.
//  Copyright 2010 jacquesfauquex@gmail.com All rights reserved.
//

#import "NSMutableDictionary+DICM.h"
#import "printfLog.h"

@implementation NSMutableDictionary(DICM)

//contenedor NSArray of NSData types long length (UT, OB, OF, OW, UN) or whichever other type transformed
#pragma mark TODO methods for C Arrays of C numbers

#pragma mark attribute
//--------------------

-(void)setDICMData:(NSData*)data forKey:(NSString*)key
{
	if (data) [self setObject:[NSArray arrayWithObject:data] forKey:key];
	else [self setObject:[NSArray array] forKey:key];
}

//input AT = SS (unsigned short,unsigned short)
- (void) setDICMATGroup:(unsigned short)group ATElement:(unsigned short)element forKey:(NSString*)key
{
	unsigned long coumpondAT = (element << 16) + group;
	[self setObject:[NSArray arrayWithObject:[NSNumber numberWithUnsignedLong:coumpondAT]] forKey:key];
}


#pragma mark numeric attribute
//----------------------------

//contenedor NSArray of NSNumber types (FL, FD, SL, SS, UL, US, AT) 
// http://developer.apple.com/iphone/library/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
// kept as NSNumber in the dictionary
// are recognize by key extension
// because NSNumber objCType set and get are not necesarily of the same type

- (void) setDICMValue:(NSNumber*)value forKey:(NSString*)key
{
	NSString *keyExt = [key pathExtension];
	if (strcmp([value objCType], @encode(short)) == 0)
	{
		short valueShort;
		[value getValue:&valueShort];
		if ([keyExt isEqualToString:@""])			[self setObject:[NSArray arrayWithObject:[NSNumber numberWithShort:valueShort]] forKey:[key stringByAppendingString:@"SS"]];
		else if ([keyExt isEqualToString:@"SS"])	[self setObject:[NSArray arrayWithObject:[NSNumber numberWithShort:valueShort]] forKey:key];
		else										printfLog(@"ERROR -> [NSMutableDictionary] mismatch: value short for %@", key);	
	}	
	else if (strcmp([value objCType], @encode(unsigned short)) == 0)
	{
		unsigned short valueUnsignedShort;
		[value getValue:&valueUnsignedShort];
		if ([keyExt isEqualToString:@""])			[self setObject:[NSArray arrayWithObject:[NSNumber numberWithUnsignedShort:valueUnsignedShort]] forKey:[key stringByAppendingString:@"US"]];
		else if ([keyExt isEqualToString:@"US"])	[self setObject:[NSArray arrayWithObject:[NSNumber numberWithShort:valueUnsignedShort]] forKey:key];
		else										printfLog(@"ERROR -> [NSMutableDictionary] mismatch: value unsigned short for %@", key);	
	}
	else if (strcmp([value objCType], @encode(long)) == 0)
	{
		long valueLong;
		[value getValue:&valueLong];
		if ([keyExt isEqualToString:@""])			[self setObject:[NSArray arrayWithObject:[NSNumber numberWithUnsignedShort:valueLong]] forKey:[key stringByAppendingString:@"SL"]];
		else if ([keyExt isEqualToString:@"SL"])	[self setObject:[NSArray arrayWithObject:[NSNumber numberWithShort:valueLong]] forKey:key];
		else										printfLog(@"ERROR -> [NSMutableDictionary] mismatch: value long for %@", key);	
	}
	else if (strcmp([value objCType], @encode(unsigned long)) == 0)
	{
		unsigned long valueUnsignedLong;
		[value getValue:&valueUnsignedLong];
		if ([keyExt isEqualToString:@""])			[self setObject:[NSArray arrayWithObject:[NSNumber numberWithUnsignedShort:valueUnsignedLong]] forKey:[key stringByAppendingString:@"UL"]];
		else if ([keyExt isEqualToString:@"UL"])	[self setObject:[NSArray arrayWithObject:[NSNumber numberWithShort:valueUnsignedLong]] forKey:key];
		else										printfLog(@"ERROR -> [NSMutableDictionary] mismatch: value unsigned long for %@", key);	
	}
	else if (strcmp([value objCType], @encode(float)) == 0)
	{
		float valueFloat;
		[value getValue:&valueFloat];
		if ([keyExt isEqualToString:@""])			[self setObject:[NSArray arrayWithObject:[NSNumber numberWithUnsignedShort:valueFloat]] forKey:[key stringByAppendingString:@"FL"]];
		else if ([keyExt isEqualToString:@"FL"])	[self setObject:[NSArray arrayWithObject:[NSNumber numberWithShort:valueFloat]] forKey:key];
		else										printfLog(@"ERROR -> [NSMutableDictionary] mismatch: value float for %@", key);	
	}
	else if (strcmp([value objCType], @encode(double)) == 0)
	{
		double valueDouble;
		[value getValue:&valueDouble];
		if ([keyExt isEqualToString:@""])			[self setObject:[NSArray arrayWithObject:[NSNumber numberWithUnsignedShort:valueDouble]] forKey:[key stringByAppendingString:@"FD"]];
		else if ([keyExt isEqualToString:@"FD"])	[self setObject:[NSArray arrayWithObject:[NSNumber numberWithShort:valueDouble]] forKey:key];
		else										printfLog(@"ERROR -> [NSMutableDictionary] mismatch: value double for %@", key);	
	}		
}


//input (FL, float, f)
- (void) setDICMFL:(float)num forKey:(NSString*)key
{
	[self setObject:[NSArray arrayWithObject:[NSNumber numberWithFloat:num]] forKey:key];
}

//input (FD, double, d)
- (void) setDICMFD:(double)num forKey:(NSString*)key
{
	[self setObject:[NSArray arrayWithObject:[NSNumber numberWithDouble:num]] forKey:key];
}

//input (SL, signed long, l)
- (void) setDICMSL:(long)num forKey:(NSString*)key
{
	[self setObject:[NSArray arrayWithObject:[NSNumber numberWithLong:num]] forKey:key];
}

//input (SS, signed short, s)
- (void) setDICMSS:(short)num forKey:(NSString*)key
{
	[self setObject:[NSArray arrayWithObject:[NSNumber numberWithShort:num]] forKey:key];
}

//input (UL, unsigned long, L)
- (void) setDICMUL:(unsigned long)num forKey:(NSString*)key
{
	[self setObject:[NSArray arrayWithObject:[NSNumber numberWithUnsignedLong:num]] forKey:key];
}

//input (US, unsigned short, S)
- (void) setDICMUS:(unsigned short)num forKey:(NSString*)key
{
	[self setObject:[NSArray arrayWithObject:[NSNumber numberWithUnsignedShort:num]] forKey:key];
}

//---------------------------------------------------------------

#pragma mark string attribute

//NSArray of NSString types (AE, AS, CS, DA, DS, DT, IS, TM, UI) + (LO, LT, PN, SH, ST)
// input NSString

- (void) setDICMString:(NSString*)string forKey:(NSString*)key
{
	if (string) [self setObject:[NSArray arrayWithObject:string] forKey:key];
	else		[self setObject:[NSArray arrayWithObject:[NSString string]] forKey:key];
}



//-----------------------------------------------------------------------------------------------
#pragma mark SQ and Item (NSArray and NSDictionary)

-(NSString*)setDICMSQForKey:(NSString*)key
{
	NSString *SQTag = [key substringToIndex:[key length]-2];
	[self setObject:[NSArray array] forKey:[SQTag stringByAppendingString:@"QX"]];
	[self setObject:[NSArray array] forKey:[SQTag stringByAppendingString:@"QZ"]];
	return [SQTag stringByAppendingString:@"QY"];
}


-(NSString*)setDICMItemForKey:(NSString*)key index:(NSUInteger)index
{
	NSString *itemTag = [key stringByAppendingString:[NSString stringWithFormat:@"%08ld",(unsigned long)index]];
	[self setObject:[NSArray array] forKey:[itemTag stringByAppendingString:@"JX"]];
	[self setObject:[NSArray array] forKey:[itemTag stringByAppendingString:@"JZ"]];
	return [itemTag stringByAppendingString:@"JY"];
}


//-----------------------------------------------------------------------------------------------
#pragma mark macros

-(void)setCodeSequenceForKey:(NSString*)k
                        code:(NSString*)c
                      scheme:(NSString*)s
                     meaning:(NSString*)m {
    if (k && c && s && m)
    {
        NSString *conceptNameCodeSequence = [self setDICMSQForKey:k];
        NSString *conceptNameCodeSequenceItem = [self setDICMItemForKey:conceptNameCodeSequence index:1];
        [self setObject:[NSArray arrayWithObject:c] forKey:[conceptNameCodeSequenceItem stringByAppendingString:@"00080100SH"]];
        [self setObject:[NSArray arrayWithObject:s] forKey:[conceptNameCodeSequenceItem stringByAppendingString:@"00080102SH"]];
        [self setObject:[NSArray arrayWithObject:m] forKey:[conceptNameCodeSequenceItem stringByAppendingString:@"00080104LO"]];
    }
}


@end
