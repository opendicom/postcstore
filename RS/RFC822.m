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


#import "RFC822.h"
static NSDateFormatter *RFC822DateFormatter;
@implementation RFC822

+ (void) initialize {
    RFC822DateFormatter = [[NSDateFormatter alloc] init];
    RFC822DateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    RFC822DateFormatter.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
    RFC822DateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
}

+(NSDate*)dateFromString:(NSString*)string
{
    return [RFC822DateFormatter dateFromString:string];
}

+(NSString*)stringFromDate:(NSDate*)date
{
    return [RFC822DateFormatter stringFromDate:date];
}

@end
