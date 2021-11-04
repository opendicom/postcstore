//
//  NSMutableString+DSCD.h
//
//  Created by jacquesfauquex on 20171217.
//  Copyright © 2017 ridi.salud.uy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (DSCD)

-(void)appendDSCDprefix;
-(void)appendSCDprefix;
-(void)appendCDAprefix;
-(void)appendCDAsuffix;
-(void)appendSCDsuffix;
-(void)appendDSCDsuffix;

-(void)appendTemplateId:(NSString*)UIDString;

//cda document ontology axis 1+2
-(void)appendCdaOntoWithTitle:(NSString*)title
               OrganizationId:(unsigned long long)organizationId
                    timestamp:(NSDate*)timestamp
                  incremental:(unsigned long)incremental
               manufacturerId:(unsigned long long)manufacturerId;

-(void)appendCdaRecordTargetWithPid:(NSString*)pid
                             issuer:(NSString*)issuer
                          apellido1:(NSString*)apellido1
                          apellido2:(NSString*)apellido2
                            nombres:(NSString*)nombres
                                sex:(NSString*)sex
                          birthdate:(NSString*)birthdate;

;
-(void)appendCdaCustodianOid:(NSString*)oid
                        name:(NSString*)name;

-(void)appendCdaRequestFrom:(NSString*)requesterName
                     issuer:(NSString*)issuer
            accessionNumber:(NSString*)accessionNumber
                   studyUID:(NSString*)studyUID
                       code:(NSString*)code
                     system:(NSString*)system
                    display:(NSString*)display
                   datetime:(NSString*)DT;

-(void)appendComponentofWithSnomedCode:(NSString*)snomedCode
                         snomedDisplay:(NSString*)snomedDisplay
                                 lowDA:(NSString*)lowDA
                                highDA:(NSString*)highDA
                           serviceCode:(NSString*)serviceCode
                           serviceName:(NSString*)serviceName;

-(void)appendEmptyComponent;

-(void)appendTextComponent:(NSString*)text;

-(void)appendUrlComponentWithPdf:(NSString*)base64;

@end
