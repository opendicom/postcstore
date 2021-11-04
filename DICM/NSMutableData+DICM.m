//
//  NSMutableData+DICM.m
//  FoundationDICM2
//
//  Created by jacquesfauquex on 10/06/13.
//  Copyright (c) 2013 jacquesfauquex@gmail.com All rights reserved.
//

#import "NSMutableData+DICM.h"
#import "const.h"
#import "printfLog.h"

const UInt32		DICM 			              = 0x4D434944;

const UInt16        version01       = 0x100;
const UInt32        version01length = 0x2;
const unsigned char	NULL1 			= 0x0;
const unsigned char	SPACE1			= ' ';
const UInt16		NULL2           = 0x0;
const UInt16		vrAE			= 0x4541;
const UInt16		vrSH			= 0x4853;
const UInt16		vrUI			= 0x4955;

const UInt64		tag00020001OB	= 0x424F00010002;
const UInt32		tag00020002	    = 0x00020002;//UI
const UInt32		tag00020003	    = 0x00030002;//UI
const UInt32		tag00020010	    = 0x00100002;//UI
const UInt32		tag00020012	    = 0x00120002;//UI
const UInt32		tag00020013	    = 0x00130002;//SH
const UInt32		tag00020016	    = 0x00160002;//AE
const UInt32		tag00020100	    = 0x01000002;//UI
const UInt64		tag00020102OB	= 0x424F01020002;

const unsigned long ascii2LittleHexa[71] =   {  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   1,
    2,   3,   4,   5,   6,   7,   8,   9,   0,   0,
    0,   0,   0,   0,   0,  10,  11,  12,  13,  14,
    15												};

const unsigned long ascii2BigHexa[71] =      {  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,  16,
    32,  48,  64,  80,  96, 112, 128, 144,   0,   0,
    0,	 0,   0,   0,   0, 160, 176, 192, 208, 224,
    240												};

//found in const.h
//const UInt16		SQ				              = 0x5153;
//const UInt16		OB				              = 0x424F;//OB for pixel fragments

const UInt32		undefinedLength	              = 0xFFFFFFFF;
const UInt64		SequenceFinalTag              = 0x00000000E0DDFFFE;
const UInt64		ItemInitialUndefinedLengthTag = 0xFFFFFFFFE000FFFE;
const UInt64		ItemFinalTag	              = 0x00000000E00DFFFE;
const uint32        ItemInitialTag                = 0xE000FFFE;


@implementation NSMutableData (DICM)

+ (id)dataWithEmptyDICMProlog {return [[NSMutableData alloc]initWithEmptyDICMProlog];}
- (id)initWithEmptyDICMProlog
{
    if (self = [super init]) return [self initWithLength:128];
    return nil;
}


- (void)appendDICMSignature
{
    [self appendBytes:&DICM length:4];
}


//------------------------------------------------------------------
#pragma mark -
#pragma mark group2


//group2 without 00020000 group length
+ (NSMutableData*)DICMDataGroup2WithDICMDictionary:(NSDictionary*)dictionary
{
    return [[NSMutableData alloc]initDICMDataGroup2WithDICMDictionary:dictionary];
}

- (id)initDICMDataGroup2WithDICMDictionary:(NSDictionary*)dictionary
{
    if (self = [super init])
    {
        //00020001 File Meta Information Version
        [self appendBytes:&tag00020001OB     length:8];
        [self appendBytes:&version01length   length:4];
        [self appendBytes:&version01         length:2];
        
        
        //00020002 MediaStorageSOPClassUID
        NSArray *array00020002=[dictionary objectForKey:@"00020002UI"];
        if ([array00020002 count]==0) printfLog(@"WARN [NSMutableData+DICM] group2 missing 00020002UI MediaStorageSOPClassUID");
        else
        {            
            NSString *attribute00020002=[array00020002 objectAtIndex:0];
            UInt16 count00020002 = (UInt16)[attribute00020002 length];
            BOOL odd00020002 = (count00020002 % 2);
            UInt16 evenCount00020002 = count00020002 + odd00020002;
            
            [self appendBytes:&tag00020002       length:4];
            [self appendBytes:&vrUI              length:2];
            [self appendBytes:&evenCount00020002 length:2];
            [self appendData:[attribute00020002 dataUsingEncoding:NSASCIIStringEncoding]];
            if (odd00020002 == TRUE) [self appendBytes:&NULL1 length:1];
            
            
            //00020003 MediaStorageSOPInstanceUID
            NSArray *array00020003=[dictionary objectForKey:@"00020003UI"];
            if ([array00020003 count]==0) printfLog(@"WARN [NSMutableData+DICM] group2 missing 00020003UI MediaStorageSOPInstanceUID");
            else
            {
                NSString *attribute00020003=[array00020003 objectAtIndex:0];
                UInt16 count00020003 = (UInt16)[attribute00020003 length];
                BOOL odd00020003 = (count00020003 % 2);
                UInt16 evenCount00020003 = count00020003 + odd00020003;
                
                [self appendBytes:&tag00020003       length:4];
                [self appendBytes:&vrUI              length:2];
                [self appendBytes:&evenCount00020003 length:2];
                [self appendData:[attribute00020003 dataUsingEncoding:NSASCIIStringEncoding]];
                if (odd00020003 == TRUE) [self appendBytes:&NULL1 length:1];
                
                
                //00020010 TransferSyntaxUID
                NSArray *array00020010=[dictionary objectForKey:@"00020010UI"];
                if ([array00020010 count]==0) printfLog(@"WARN [NSMutableData+DICM] group2 missing 00020010UI TransferSyntaxUID");
                else
                {
                    NSString *attribute00020010=[array00020010 objectAtIndex:0];
                    UInt16 count00020010 = (UInt16)[attribute00020010 length];
                    BOOL odd00020010 = (count00020010 % 2);
                    UInt16 evenCount00020010 = count00020010 + odd00020010;
                    
                    [self appendBytes:&tag00020010       length:4];
                    [self appendBytes:&vrUI              length:2];
                    [self appendBytes:&evenCount00020010 length:2];
                    [self appendData:[attribute00020010 dataUsingEncoding:NSASCIIStringEncoding]];
                    if (odd00020010 == TRUE) [self appendBytes:&NULL1 length:1];
                    
                    
                    //00020012 ImplementationClassUID
                    NSArray *array00020012=[dictionary objectForKey:@"00020012UI"];
                    if ([array00020012 count]==0) printfLog(@"WARN [NSMutableData+DICM] group2 missing 00020010UI ImplementationClassUID");
                    else
                    {
                        NSString *attribute00020012=[array00020012 objectAtIndex:0];
                        UInt16 count00020012 = (UInt16)[attribute00020012 length];
                        BOOL odd00020012 = (count00020012 % 2);
                        UInt16 evenCount00020012 = count00020012 + odd00020012;
                        
                        [self appendBytes:&tag00020012       length:4];
                        [self appendBytes:&vrUI              length:2];
                        [self appendBytes:&evenCount00020012 length:2];
                        [self appendData:[attribute00020012 dataUsingEncoding:NSASCIIStringEncoding]];
                        if (odd00020012 == TRUE) [self appendBytes:&NULL1 length:1];
                        
                        
                        
                        //00020013 (opcional) Implementation version name
                        NSArray *array00020013=[dictionary objectForKey:@"00020013SH"];
                        if ([array00020013 count]==1)
                        {
                            NSString *attribute00020013=[array00020013 objectAtIndex:0];
                            UInt16 count00020013 = (UInt16)[attribute00020013 length];
                            BOOL odd00020013 = (count00020013 % 2);
                            UInt16 evenCount00020013 = count00020013 + odd00020013;
                            
                            [self appendBytes:&tag00020013       length:4];
                            [self appendBytes:&vrSH              length:2];
                            [self appendBytes:&evenCount00020013 length:2];
                            [self appendData:[attribute00020013 dataUsingEncoding:NSASCIIStringEncoding]];
                            if (odd00020013 == TRUE) [self appendBytes:&SPACE1 length:1];
                        }
                        
                        
                        //00020016 (opcional) Source Application Entity Title
                        NSArray *array00020016=[dictionary objectForKey:@"00020016AE"];
                        if ([array00020016 count]==1)
                        {
                            NSString *attribute00020016=[array00020016 objectAtIndex:0];
                            UInt16 count00020016 = (UInt16)[attribute00020016 length];
                            BOOL odd00020016 = (count00020016 % 2);
                            UInt16 evenCount00020016 = count00020016 + odd00020016;
                            
                            [self appendBytes:&tag00020016       length:4];
                            [self appendBytes:&vrAE              length:2];
                            [self appendBytes:&evenCount00020016 length:2];
                            [self appendData:[attribute00020016 dataUsingEncoding:NSASCIIStringEncoding]];
                            if (odd00020016 == TRUE) [self appendBytes:&SPACE1 length:1];
                        }
                        
                        
                        //00020100 + 00020102 (opcional) Private Information Creatior UID and Private Information
                        NSArray *array00020100=[dictionary objectForKey:@"00020100UI"];
                        NSArray *array00020102=[dictionary objectForKey:@"00020102OB"];
                        if (([array00020100 count]==1)&&([array00020102 count]==1))
                        {
                            NSString *attribute00020100=[array00020100 objectAtIndex:0];
                            UInt16 count00020100 = (UInt16)[attribute00020100 length];
                            BOOL odd00020100 = (count00020100 % 2);
                            UInt16 evenCount00020100 = count00020100 + odd00020100;
                            
                            [self appendBytes:&tag00020100       length:4];
                            [self appendBytes:&vrUI              length:2];
                            [self appendBytes:&evenCount00020100 length:2];
                            [self appendData:[attribute00020100 dataUsingEncoding:NSASCIIStringEncoding]];
                            if (odd00020100 == TRUE) [self appendBytes:&NULL1 length:1];
                            
                            
                            NSData *data00020102=[array00020102 objectAtIndex:0];
                            UInt32 count00020102 = (UInt32)[data00020102 length];
                            BOOL odd00020102 = (count00020102 % 2);
                            UInt32 evenCount00020102 = count00020102 + odd00020102;
                            
                            [self appendBytes:&tag00020102OB     length:8];
                            [self appendBytes:&evenCount00020102 length:4];
                            [self appendData:data00020102];
                            if (odd00020102 == TRUE) [self appendBytes:&NULL1 length:1];                            
                        }
                        
                        return self;//printfLog(@"INFO [NSMutableData+DICM] group2 initialized");
                    }
                }
            }
        }
    }
    return nil;
}


+ (NSMutableData*)DICMDataWithDICMDictionary:(NSDictionary*)dictionary bulkdataBaseURI:(NSURL*)bulkdataBaseURI
{
    return [[NSMutableData alloc]initDICMDataWithDICMDictionary:dictionary bulkdataBaseURI:bulkdataBaseURI];
}
- (id)initDICMDataWithDICMDictionary:(NSDictionary*)dictionary bulkdataBaseURI:(NSURL*)bulkdataBaseURI
{
    if (!dictionary || ([dictionary count]==0)) return nil;
    if (self = [super init])
    {
        NSStringEncoding stringEncodingStack[20];
        NSUInteger       encapsulationDepth=0;
        stringEncodingStack[encapsulationDepth]=NSASCIIStringEncoding;
        for (NSString *key in [[dictionary allKeys]sortedArrayUsingSelector:@selector(compare:)])
        {
            //printfLog(@"%@",key);
            NSStringEncoding returnedStringEncoding=[self appendDICMAttribute:key withObject:[dictionary objectForKey:key] bulkdataBaseURI:bulkdataBaseURI stringEncoding:stringEncodingStack[encapsulationDepth]];            

            if (returnedStringEncoding==65534)//item beginning
            {
                stringEncodingStack[encapsulationDepth+1]=stringEncodingStack[encapsulationDepth];
                encapsulationDepth++;
            }
            else if (returnedStringEncoding==65533) encapsulationDepth--;//item end
            else if (returnedStringEncoding!=65535) stringEncodingStack[encapsulationDepth]=returnedStringEncoding;//00080005 (65535 = no changes)
        }
    }
    return self;	
}


- (NSStringEncoding)appendDICMAttribute:(NSString*)tagPath withObject:(id)object bulkdataBaseURI:(NSURL*)bulkdataBaseURI stringEncoding:(NSStringEncoding)stringEncoding
{
    //object may be NSData (inlined data) or NSArray (array of strings) or NSString (bulkdata)
    NSStringEncoding returnedStringEncoding=65535;//by default without changes
    
    NSUInteger tagPathLength = [tagPath length];
    if ((tagPathLength<10) || ((tagPathLength%10)!=0)) printfLog(@"ERROR [DICMData] bad tagPath '%@'",tagPath);
    else
    {
        NSString *vr=[tagPath substringFromIndex:tagPathLength-2];
        NSString *tag=[tagPath substringWithRange:NSMakeRange(tagPathLength-10,8)];
        UInt32 tagLe = (UInt32)(((ascii2BigHexa[[tag characterAtIndex:0]] + ascii2LittleHexa[[tag characterAtIndex:1]]) <<  8) +
                                ((ascii2BigHexa[[tag characterAtIndex:2]] + ascii2LittleHexa[[tag characterAtIndex:3]]) <<  0) +
                                ((ascii2BigHexa[[tag characterAtIndex:4]] + ascii2LittleHexa[[tag characterAtIndex:5]]) << 24) +
                                ((ascii2BigHexa[[tag characterAtIndex:6]] + ascii2LittleHexa[[tag characterAtIndex:7]]) << 16));
        
        //printfLog(@"debug %@.%@",tag,vr);
        unsigned short vrLe = ([vr characterAtIndex:1] << 8) + [vr characterAtIndex:0];
        
        
        
        NSMutableData *compoundData = [NSMutableData dataWithLength:0];
        switch (vrLe)
        {
                
#pragma mark string
#pragma mark UI                
                //0x00 padded
            case 0x4955:;//UI
                if ([object count]==0) [self appendDICM8NullPadded:tagLe vr:vrLe string:@""];
                else                   [self appendDICM8NullPadded:tagLe vr:vrLe string:[object componentsJoinedByString:@"\\"]];
                break;
                
#pragma mark CS
                // ISO-IR 6 string
            case 0x5343:;//CS
                if ([object count]==0) returnedStringEncoding=[self CSappendDICM8SpacePadded:tagLe vr:vrLe string:@""];
                else                   returnedStringEncoding=[self CSappendDICM8SpacePadded:tagLe vr:vrLe string:[object componentsJoinedByString:@"\\"]];
                break;


#pragma mark AE AS DA DS DT IS TM
                // ISO-IR 6 string
            case 0x4541:;//AE
            case 0x5341:;//AS
            case 0x4144:;//DA
            case 0x5344:;//DS
            case 0x5444:;//DT
            case 0x5349:;//IS
            case 0x4D54:;//TM
                if ([object count]==0)
                     [self appendDICM8SpacePaddedASCII:tagLe vr:vrLe string:@""];
                else [self appendDICM8SpacePaddedASCII:tagLe vr:vrLe string:[object componentsJoinedByString:@"\\"]];
                break;                
                
#pragma mark LO LT PN SH ST                
                // 00080005 stringEncoding
            case 0x4F4C:;//LO
            case 0x544C:;//LT
            case 0x4E50:;//PN
            case 0x4853:;//SH
            case 0x5453:;//ST
                if ([object count]==0)
                     [self appendDICM8SpacePadded:tagLe vr:vrLe string:@""                                     stringEncoding:stringEncoding];
                else [self appendDICM8SpacePadded:tagLe vr:vrLe string:[object componentsJoinedByString:@"\\"] stringEncoding:stringEncoding];
                break;
                
 #pragma mark UT               
            case 0x5455:;//UT not multivalued
                NSUInteger objectCount = [object count];
                if      (objectCount==0) [self appendDICM12:tagLe vr:vrLe string:@""                                     stringEncoding:stringEncoding];
                else if (objectCount ==1)[self appendDICM12:tagLe vr:vrLe string:[object componentsJoinedByString:@"\\"] stringEncoding:stringEncoding];
                else  printfLog(@"ERROR [DICMData] tagPath '%@' can´t contain multi values",tagPath);
                break;
                
                
#pragma mark num
#pragma mark FL FD SL SS UL US AT
                //kept as array of string

            case 0x4C46://FL
            {
                for (NSString *stringNumber in object)
                {
                    float f = [stringNumber floatValue];
                    [compoundData appendBytes:&f length:4];
                }
                [self appendDICM8:tagLe vr:vrLe data:compoundData];
                break;
            }
                
            case 0x4446://FD
            {
                for (NSString *stringNumber in object)
                {
                    double d = [stringNumber doubleValue];
                    [compoundData appendBytes:&d length:8];
                }
                [self appendDICM8:tagLe vr:vrLe data:compoundData];
                break;
            }
                
            case 0x4C53://SL
            {
                for (NSString *stringNumber in object)
                {
                    SInt32 si32 = (SInt32)[stringNumber longLongValue];
                    [compoundData appendBytes:&si32 length:4];
                }
                [self appendDICM8:tagLe vr:vrLe data:compoundData];
                break;
            }
                
            case 0x5353://SS
            {
                for (NSString *stringNumber in object)
                {
                    SInt16 si16 = (SInt16)[stringNumber longLongValue];
                    [compoundData appendBytes:&si16 length:2];
                }
                [self appendDICM8:tagLe vr:vrLe data:compoundData];
                break;
            }
                
            case 0x4C55://UL
            {
                for (NSString *stringNumber in object)
                {
                    UInt32 ui32 = (SInt32)[stringNumber longLongValue];
                    [compoundData appendBytes:&ui32 length:4];
                }
                [self appendDICM8:tagLe vr:vrLe data:compoundData];
                break;
            }
                
            case 0x5355://US
            {
                for (NSString *stringNumber in object)
                {
                    UInt16 ui16 = (UInt16)[stringNumber longLongValue];
                    [compoundData appendBytes:&ui16 length:2];
                }
                [self appendDICM8:tagLe vr:vrLe data:compoundData];
                break;
            }
                
            case 0x5441://AT
            {
                //receiving string ..........ttttttttvr
                //to be transformed in group unsigned short and element unsigned short
                for (NSString *ATTagPath in object)
                {
                    NSUInteger ATTagPathLength = [ATTagPath length];
                    if ((ATTagPathLength<9) || ((ATTagPathLength%10)!=0)) printfLog(@"ERROR [DICMData] bad AT tag '%@',",ATTagPath);
                    else
                    {
                        NSString *ATTag=[tagPath substringWithRange:NSMakeRange(tagPathLength-10,tagPathLength-2)];
                        UInt32 ATTagLe = (UInt32)(((ascii2BigHexa[[ATTag characterAtIndex:0]] + ascii2LittleHexa[[ATTag characterAtIndex:1]]) <<  8) +
                                                  ((ascii2BigHexa[[ATTag characterAtIndex:2]] + ascii2LittleHexa[[ATTag characterAtIndex:3]]) <<  0) +
                                                  ((ascii2BigHexa[[ATTag characterAtIndex:4]] + ascii2LittleHexa[[ATTag characterAtIndex:5]]) << 24) +
                                                  ((ascii2BigHexa[[ATTag characterAtIndex:6]] + ascii2LittleHexa[[ATTag characterAtIndex:7]]) << 16));
                        [compoundData appendBytes:&ATTagLe length:4];
                    }
                }
                [self appendDICM8:tagLe vr:vrLe data:compoundData];
                break;
            }
                
#pragma mark OB OF OW UN (inlined data)               
                // UInt32 byteCount datas
                // dictionary contents
            case 0x424F://OB
            case 0x464F://OF
            case 0x574F://OW
            case 0x4E55://UN
            {
                //VM=1
                [self appendDICM12:tagLe vr:vrLe data:object[0]];
                break;
            }
                
                
#pragma mark data
#pragma mark KB KF KW KN (bulkdata URI to be fetched before incorporation into the DICOM file)
                
                // UInt32 byteCount datas
                // binay contents
            case 0x424B://KB
            case 0x464B://KF
            case 0x574B://KW
            case 0x4E4B://KN
            {
                //if ([object isKindOfClass:[NSString class]])
                NSData *bulkData = [NSData dataWithContentsOfURL:[bulkdataBaseURI URLByAppendingPathComponent:object isDirectory:false]];
                if (bulkData)[self appendDICM12:tagLe vr:vrLe data:bulkData];
                else printfLog(@"ERROR [DICMData] bulkdataURL %@ is not reachable",object);
                break;
            }
                
#pragma mark containers
#pragma mark QK QX QZ JX JZ KG GX GZ
                
                //sequence and item

            case 0x4B51://QK
            {
                //sequence with bulkdata contents
                break;
            }
                
            case 0x5851://QX
            {
                //sequence opening tag
                [self appendBytes:&tagLe		    length:4];
                [self appendBytes:&SQ			    length:2];
                [self appendBytes:&NULL1		    length:1];
                [self appendBytes:&NULL1		    length:1];
                [self appendBytes:&undefinedLength  length:4];
                break;
            }
            case 0x5A51://QZ
            {
                [self appendBytes:&SequenceFinalTag length:8];
                break;
            }
                
                
            case 0x584A://JX
            {
                //item opening tag
                [self appendBytes:&ItemInitialUndefinedLengthTag length:8];
                returnedStringEncoding=65534;//more encapsulation
                break;
            }
            case 0x5A4A://JZ
            {
                [self appendBytes:&ItemFinalTag length:8];
                returnedStringEncoding=65533;//less encapsulation
                break;
            }
                
                
            case 0x5847://GX
            {
                //pixel fragments initial marker
                [self appendBytes:&tagLe		   length:4];
                [self appendBytes:&OB              length:2];
                [self appendBytes:&NULL1		   length:1];
                [self appendBytes:&NULL1		   length:1];
                [self appendBytes:&undefinedLength length:4];
                break;
            }
            case 0x5A47://GZ
            {
                //pixel fragments final marker
                [self appendBytes:&SequenceFinalTag length:8];
                break;
            }
                
            case 0x5959://YY
            {
                //pixel fragments (items with DEFINED length, followed by fragment)
                //E07F1000 4F420000 FFFFFFFF FEFF00E 000000000 FEFF00E0 7EC68300
                [self appendBytes:&ItemInitialTag length:4];
                UInt32 fragmentLength = (UInt32)[object length];
                UInt32 evenBoundary = fragmentLength % 2;
                fragmentLength+=evenBoundary;
                [self appendBytes:&fragmentLength length:4];
                [self appendBytes:(__bridge const void * _Nonnull)(object) length:fragmentLength-evenBoundary];
                if (evenBoundary==1) [self appendBytes:&NULL1 length:1];
                break;
            }
                
            case 0x594B://KY
            {
                //pixel fragment bulkdata
                NSData *fragmentBulkData = [NSData dataWithContentsOfURL:[bulkdataBaseURI URLByAppendingPathComponent:object isDirectory:false]];
                if (!fragmentBulkData) printfLog(@"ERROR [DICMData] bulkdataURL %@ is not reachable",object);
                else
                {
                    [self appendBytes:&ItemInitialTag length:4];                    
                    UInt32 fragmentLength = (UInt32)[fragmentBulkData length];
                    UInt32 evenBoundary = fragmentLength % 2;
                    fragmentLength+=evenBoundary;
                    [self appendBytes:&fragmentLength length:4];
                    [self appendBytes:(__bridge const void * _Nonnull)(fragmentBulkData) length:fragmentLength-evenBoundary];
                    if (evenBoundary==1) [self appendBytes:&NULL1 length:1];
                }
                break;
            }
            default:
            {
                printfLog(@"WARN -> [DICMData] unknown %@ vr for tag %u",vr, (unsigned int)tagLe);
                break;
            }
        }
    }
    return returnedStringEncoding;
}


//CS
- (NSStringEncoding)CSappendDICM8SpacePadded:(UInt32)tag vr:(UInt16)vr string:(NSString*)compoundString
{
	//character length != byte length because of utf multi-byte character encoding for instance Ñ
	UInt16 bytesCount = (UInt16)[compoundString length];
	BOOL odd = (bytesCount % 2);
	UInt16 bytesEvenCount = bytesCount + odd;
	
	[self appendBytes:&tag						length:4];
	[self appendBytes:&vr						length:2];
	[self appendBytes:&bytesEvenCount			length:2];
	[self appendData:[compoundString dataUsingEncoding:NSASCIIStringEncoding]];
	if (odd == TRUE) [self appendBytes:&SPACE1	length:1];
    
    if (tag==0x80005)//charset
    {
        NSArray *stringParts = [compoundString componentsSeparatedByString:@"\\"];
        if ([stringParts count])
        {
            NSString *firstCharsetDICM=[stringParts objectAtIndex:0];
            if ([firstCharsetDICM isEqualToString:@"ISO-IR 100"])      return NSISOLatin1StringEncoding;
            else if ([firstCharsetDICM isEqualToString:@"ISO-IR 192"]) return NSUTF8StringEncoding;
            else if ([firstCharsetDICM isEqualToString:@"ISO-IR 6"])   return NSASCIIStringEncoding;
            //this is extensible
        }
    }
    return 65535;//no changes
}


//AE AS DA DS DT IS TM
- (void)appendDICM8SpacePaddedASCII:(UInt32)tag vr:(UInt16)vr string:(NSString*)compoundString
{
	//character length != byte length because of utf multi-byte character encoding for instance Ñ
	UInt16 bytesCount = (UInt16)[compoundString length];
	BOOL odd = (bytesCount % 2);
	UInt16 bytesEvenCount = bytesCount + odd;
	
	[self appendBytes:&tag						length:4];
	[self appendBytes:&vr						length:2];
	[self appendBytes:&bytesEvenCount			length:2];
	[self appendData:[compoundString dataUsingEncoding:NSASCIIStringEncoding]];
	if (odd == TRUE) [self appendBytes:&SPACE1	length:1];
}


//LO SH LT ST PN
- (void)appendDICM8SpacePadded:(UInt32)tag vr:(UInt16)vr string:(NSString*)compoundString stringEncoding:(NSStringEncoding)stringEncoding
{
	//character length != byte length because of utf multi-byte character encoding for instance Ñ
	UInt16 bytesCount = (UInt16)[compoundString lengthOfBytesUsingEncoding:stringEncoding];
	BOOL odd = (bytesCount % 2);
	UInt16 bytesEvenCount = bytesCount + odd;
	
	[self appendBytes:&tag						length:4];
	[self appendBytes:&vr						length:2];
	[self appendBytes:&bytesEvenCount			length:2];
	[self appendData:[compoundString dataUsingEncoding:stringEncoding]];
	if (odd == TRUE) [self appendBytes:&SPACE1	length:1];
}


//UI
- (void)appendDICM8NullPadded:(UInt32)tag vr:(UInt16)vr string:(NSString*)compoundString
{
	UInt16 bytesCount = (UInt16)[compoundString length];
	BOOL odd = (bytesCount % 2);
	UInt16 bytesEvenCount = bytesCount + odd;
	
	[self appendBytes:&tag                    length:4];
	[self appendBytes:&vr                     length:2];
	[self appendBytes:&bytesEvenCount         length:2];
	[self appendData:[compoundString dataUsingEncoding:NSASCIIStringEncoding]];
	if (odd == TRUE) [self appendBytes:&NULL1 length:1];
}

//UT
- (void)appendDICM12:(UInt32)tag vr:(UInt16)vr string:(NSString*)compoundString stringEncoding:(NSStringEncoding)stringEncoding
{
	UInt32 bytesCount = (UInt32)[compoundString lengthOfBytesUsingEncoding:stringEncoding];
	BOOL odd = (bytesCount % 2);
	UInt32 bytesEvenCount = bytesCount + odd;
	
	[self appendBytes:&tag						length:4];
	[self appendBytes:&vr						length:2];
	[self appendBytes:&NULL1					length:1];
	[self appendBytes:&NULL1					length:1];
	[self appendBytes:&bytesEvenCount			length:4];
	[self appendData:[compoundString dataUsingEncoding:stringEncoding]];
	if (odd == TRUE) [self appendBytes:&SPACE1	length:1];
}

//FD FL SL UL SS US
- (void)appendDICM8:(UInt32)tag vr:(UInt16)vr data:(NSData*)compoundData
{
	UInt16 bytesCount = (UInt16)[compoundData length];
	BOOL odd = (bytesCount % 2);
	UInt32 bytesEvenCount = bytesCount + odd;
    
	[self appendBytes:&tag                    length:4];
	[self appendBytes:&vr                     length:2];
	[self appendBytes:&bytesEvenCount         length:2];
	[self appendData:compoundData];
	if (odd == TRUE) [self appendBytes:&NULL1 length:1];
}

// SQ, OF, OW, OB or UN
- (void)appendDICM12:(UInt32)tag vr:(UInt16)vr data:(NSData*)compoundData
{
	UInt32 bytesCount = (UInt32)[compoundData length];
	BOOL odd = (bytesCount % 2);
	UInt32 bytesEvenCount = bytesCount + odd;
	
	[self appendBytes:&tag					  length:4];
	[self appendBytes:&vr					  length:2];
	[self appendBytes:&NULL1				  length:1];
	[self appendBytes:&NULL1				  length:1];
	[self appendBytes:&bytesEvenCount		  length:4];
	[self appendData:compoundData];
	if (odd == TRUE) [self appendBytes:&NULL1 length:1];
}

@end
