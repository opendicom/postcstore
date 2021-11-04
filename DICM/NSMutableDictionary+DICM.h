//
//  NSMutableDictionary+DICM.h
//  FoundationDICM2
//
//  Created by jacques on 20100824.
//  Copyright 2010 jacquesfauquex@gmail.com All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSMutableDictionary(DICM)


//creates NSArray of NSData types long length (UT, OB, OF, OW, UN) + AT
-(void)setDICMData:(NSData*)data forKey:(NSString*)key;
-(void)setDICMATGroup:(unsigned short)group ATElement:(unsigned short)element forKey:(NSString*)key;


//-----------------------------------------------------------------
//creates NSArray of NSNumber types (FL, FD, SL, SS, UL, US, AT) 
// http://developer.apple.com/iphone/library/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
// kept as NSNumber in the Dictionary_DICM
// are recognized by key extension
// because NSNumber objCType set and get are not necesarily of the same type

-(void)setDICMValue:(NSValue*)value forKey:(NSString*)key;					 

-(void)setDICMFL:(float)num forKey:(NSString*)key;
-(void)setDICMFD:(double)num forKey:(NSString*)key;
-(void)setDICMSL:(long)num forKey:(NSString*)key;
-(void)setDICMSS:(short)num forKey:(NSString*)key;
-(void)setDICMUL:(unsigned long)num forKey:(NSString*)key;
-(void)setDICMUS:(unsigned short)num forKey:(NSString*)key;


//-----------------------------------------------------------------------------------------------
//creates NSArray of NSString types (AE, AS, CS, DA, DS, DT, IS, TM, UI) + (LO, LT, PN, SH, ST)

// input NSString
-(void)setDICMString:(NSString*)string forKey:(NSString*)key;

//-----------------------------------------------------------------------------------------------
//create empty NSArray of SQ and Item

-(NSString*)setDICMSQForKey:(NSString*)key;
-(NSString*)setDICMItemForKey:(NSString*)key index:(NSUInteger)index;
-(void)setCodeSequenceForKey:(NSString*)k
                        code:(NSString*)c
                      scheme:(NSString*)s
                     meaning:(NSString*)m;

@end
