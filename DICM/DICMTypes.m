//
//  Created by jacquesfauquex on 20171122.
//  Copyright © 2018 opendicom.com. All rights reserved.
//

/*
 Copyright:  Copyright (c) 2017 jacques.fauquex@opendicom.com All Rights Reserved.
 
 This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
 If a copy of the MPL was not distributed with this file, You can obtain one at
 http://mozilla.org/MPL/2.0/
 
 Covered Software is provided under this License on an “as is” basis, without warranty of
 any kind, either expressed, implied, or statutory, including, without limitation,
 warranties that the Covered Software is free of defects, merchantable, fit for a particular
 purpose or non-infringing. The entire risk as to the quality and performance of the Covered
 Software is with You. Should any Covered Software prove defective in any respect, You (not
 any Contributor) assume the cost of any necessary servicing, repair, or correction. This
 disclaimer of warranty constitutes an essential part of this License. No use of any Covered
 Software is authorized under this License except under this disclaimer.
 
 Under no circumstances and under no legal theory, whether tort (including negligence),
 contract, or otherwise, shall any Contributor, or anyone who distributes Covered Software
 as permitted above, be liable to You for any direct, indirect, special, incidental, or
 consequential damages of any character including, without limitation, damages for lost
 profits, loss of goodwill, work stoppage, computer failure or malfunction, or any and all
 other commercial damages or losses, even if such party shall have been informed of the
 possibility of such damages. This limitation of liability shall not apply to liability for
 death or personal injury resulting from such party’s negligence to the extent applicable
 law prohibits such limitation. Some jurisdictions do not allow the exclusion or limitation
 of incidental or consequential damages, so this exclusion and limitation may not apply to
 You.
 */


#import "DICMTypes.h"

static NSISO8601DateFormatter *ISO8601yyyyMMdd;
static NSISO8601DateFormatter *ISO8601yyyyMMddhhmmss;

static NSDate *dateZero;
static NSDateFormatter *yyyyFormatter=nil;
static NSDateFormatter *MMFormatter=nil;
static NSDateFormatter *ddFormatter=nil;
static NSDateFormatter *DTFormatter=nil;
static NSDateFormatter *DAFormatter=nil;
static NSDateFormatter *TMFormatter=nil;
static NSRegularExpression *UIRegex=nil;
static NSRegularExpression *SHRegex=nil;
static NSRegularExpression *DARegex=nil;

@implementation DICMTypes

+ (void) initialize {
    ISO8601yyyyMMdd=[[NSISO8601DateFormatter alloc]init];
    ISO8601yyyyMMdd.formatOptions=NSISO8601DateFormatWithFullDate;
    ISO8601yyyyMMddhhmmss=[[NSISO8601DateFormatter alloc]init];
    ISO8601yyyyMMddhhmmss.formatOptions=NSISO8601DateFormatWithFullDate|NSISO8601DateFormatWithFullTime;

    dateZero=[ISO8601yyyyMMdd dateFromString:@"00000101"];
    yyyyFormatter = [[NSDateFormatter alloc] init];
    [yyyyFormatter setDateFormat:@"yyyy"];
    MMFormatter = [[NSDateFormatter alloc] init];
    [MMFormatter setDateFormat:@"MM"];
    ddFormatter = [[NSDateFormatter alloc] init];
    [ddFormatter setDateFormat:@"dd"];
    DTFormatter = [[NSDateFormatter alloc] init];
    [DTFormatter setDateFormat:@"yyyyMMddHHmmss"];
    DAFormatter = [[NSDateFormatter alloc] init];
    [DAFormatter setDateFormat:@"yyyyMMdd"];
    TMFormatter = [[NSDateFormatter alloc] init];
    [TMFormatter setDateFormat:@"HHmmss"];

    UIRegex = [NSRegularExpression regularExpressionWithPattern:@"^[1-2](\\d)*(\\.0|\\.[1-9](\\d)*)*$" options:0 error:NULL];
    SHRegex = [NSRegularExpression regularExpressionWithPattern:@"^(?:\\s*)([^\\r\\n\\f\\t]*[^\\r\\n\\f\\t\\s])(?:\\s*)$" options:0 error:NULL];
    DARegex = [NSRegularExpression regularExpressionWithPattern:@"^(19|20)\\d\\d(01|02|03|04|05|06|07|08|09|10|11|12)(01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31)$" options:0 error:NULL];


}

+(NSDate*)dateFromDAString:(NSString*)string
{
    return [DAFormatter dateFromString:string];
}

+(NSString*)DAStringFromDate:(NSDate*)date
{
    return [DAFormatter stringFromDate:date];
}

+(NSDate*)dateFromTMString:(NSString*)string
{
    return [TMFormatter dateFromString:string];
}

+(NSString*)TMStringFromDate:(NSDate*)date
{
    return [TMFormatter stringFromDate:date];
}

+(NSDate*)dateFromDTString:(NSString*)string
{
    return [DTFormatter dateFromString:string];
}

+(NSString*)DTStringFromDate:(NSDate*)date
{
    return [DTFormatter stringFromDate:date];
}

+(NSString*)ASSinceDate:(NSDate*)sinceDate untilDate:(NSDate*)untilDate
{
    if (!sinceDate || !untilDate) return @"????";
    NSTimeInterval seconds=[untilDate timeIntervalSinceDate:sinceDate];
    NSDate *sinceDateZero=[dateZero dateByAddingTimeInterval:seconds];

    int years=[[yyyyFormatter stringFromDate:sinceDateZero] intValue];
    if( years > 1) return [NSString stringWithFormat: @"%03dY", years];

    int months=[[MMFormatter stringFromDate:sinceDateZero] intValue];
    if (years || months > 8) return [NSString stringWithFormat: @"%03dM", months + (years * 12)];
    
    if (months > 2) return [NSString stringWithFormat: @"%03dW", (int)(seconds / 604800)];
    
    return [NSString stringWithFormat: @"%03dD", (int)(seconds / 86400)];
}

+(NSString*)ASSinceDA:(NSString*)sinceDA untilDA:(NSString*)untilDA
{
    NSDate *sinceDate=[ISO8601yyyyMMdd dateFromString:sinceDA];
    NSDate *untilDate=[ISO8601yyyyMMdd dateFromString:untilDA];
    if (!sinceDate || !untilDate) return @"????";
    return [DICMTypes ASSinceDate:sinceDate untilDate:untilDate];
}
@end
