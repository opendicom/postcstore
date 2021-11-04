//
//  NSMutableURLRequest+PCS.h

//
//  Created by jacquesfauquex on 2017129.
//  Copyright © 2017 ridi.salud.uy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (PCS)


+(id)POSTenclosed:(NSString*)URLString
               CS:(NSString*)CS
              aet:(NSString*)aet
               DA:(NSString*)DA
               TM:(NSString*)TM
               TZ:(NSString*)TZ
         modality:(NSString*)modality
  accessionNumber:(NSString*)accessionNumber
           status:(NSString*)status
         procCode:(NSString*)procCode
       procScheme:(NSString*)procScheme
      procMeaning:(NSString*)procMeaning
         priority:(NSString*)priority
             name:(NSString*)name
              pid:(NSString*)pid
           issuer:(NSString*)issuer
        birthdate:(NSString*)birthdate
              sex:(NSString*)sex
      instanceUID:(NSString*)instanceUID
        seriesUID:(NSString*)seriesUID
         studyUID:(NSString*)studyUID
     seriesNumber:(NSString*)seriesNumber
seriesDescription:(NSString*)seriesDescription
  enclosureHL7II:(NSString*)enclosureHL7II
   enclosureTitle:(NSString*)enclosureTitle
    enclosureTransferSyntax:(NSString*)enclosureTransferSyntax
    enclosureData:(NSData*)enclosureData
      contentType:(NSString*)contentType
          timeout:(NSTimeInterval)timeout
;

@end
