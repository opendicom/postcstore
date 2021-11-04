//
//  NSMutableURLRequest+PCS.m

//
//  Created by jacquesfauquex on 2017129.
//  Copyright © 2017 ridi.salud.uy. All rights reserved.
//

#import "NSMutableURLRequest+PCS.h"
#import "NSDictionary+DICM.h"
#import "NSMutableDictionary+DICM.h"
#import "NSMutableData+DICM.h"
#import "NSUUID+DICM.h"

@implementation NSMutableURLRequest (PCS)

const UInt32        tag00020000     = 0x02;
const UInt32        vrULmonovalued  = 0x044C55;


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
{
    if (!URLString || ![URLString length]) return nil;
    if (!pid || ![pid length]) return nil;
    if (!issuer || ![issuer length]) return nil;
    if ([contentType isEqualToString:@"application/dicom"])
    {
        //minimal format, one step with accessionNumber=procid=stepid=studyiuid
        NSMutableDictionary *metainfo=[NSMutableDictionary dictionary];
        [metainfo addEntriesFromDictionary:[NSDictionary
                                            DICM0002ForMediaStorageSOPClassUID:@"1.2.840.10008.5.1.4.1.1.104.2"
                                            mediaStorageSOPInstanceUID:instanceUID
                                            implementationClassUID:@""
                                            implementationVersionName:@""
                                            sourceApplicationEntityTitle:@""
                                            privateInformationCreatorUID:@""
                                            privateInformation:nil]];
        NSMutableData *metainfoData=[NSMutableData DICMDataGroup2WithDICMDictionary:metainfo];

        NSMutableDictionary *dicm=[NSMutableDictionary dictionary];

        //DICMC120100    SOP Common
         [dicm addEntriesFromDictionary:[NSDictionary
          DICMC120100ForSOPClassUID1:@"1.2.840.10008.5.1.4.1.1.104.2"
                     SOPInstanceUID1:instanceUID
                            charset1:CS
                                 DA1:DA
                                 TM1:TM
                                  TZ:TZ]];
        
        //DICMC070101    Patient
        [dicm addEntriesFromDictionary:[NSDictionary
         DICMC070101PatientWithName:name
                         pid:pid
                      issuer:issuer
                   birthdate:birthdate
                         sex:sex]];

        //DICMC070201    General Study
        [dicm addEntriesFromDictionary:[NSDictionary
         DICMC070201StudyWithUID:accessionNumber
                              DA:DA
                              TM:TM
                              ID:@""
                              AN:accessionNumber
                          issuer:@""
                            name:procMeaning
                            code:procCode
                          scheme:procScheme
                         meaning:procMeaning]];

        
        //DICMC240100    Encapsulated Series
        [dicm addEntriesFromDictionary:[NSDictionary
         DICMC240100ForModality1:@"OT"
                      seriesUID1:seriesUID
                   seriesNumber2:@"-32"
                       seriesDA3:DA
                       seriesTM3:TM
              seriesDescription3:seriesDescription]];
        
        //DICMC070501    General Equipment
        [dicm addEntriesFromDictionary:[NSDictionary DICMC070501]];
        
        //DICMC080601    SC Equipment
        [dicm addEntriesFromDictionary:[NSDictionary
         DICMC080601ForConversionType1:@"WSD"]];

        //DICMC240200    Encapsulated Document
        [dicm addEntriesFromDictionary:[NSDictionary
         DICMC240200EncapsulatedCDAWithDA:DA
                                       TM:TM
                                    title:enclosureTitle
                                    HL7II:enclosureHL7II
                                     data:enclosureData]];


        //MutableDictionary -> NSMutableData
        
        NSString *boundaryString=[[NSUUID UUID]UUIDString];

        NSMutableData *stowData=[NSMutableData data];
        
        [stowData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\nContent-Type:application/dicom\r\n\r\n",boundaryString] dataUsingEncoding:NSASCIIStringEncoding]];
        
        [stowData increaseLengthBy:128];
        [stowData appendDICMSignature];
        
        UInt32 count00020000 = (UInt32)[metainfoData length];
        [stowData appendBytes:&tag00020000    length:4];
        [stowData appendBytes:&vrULmonovalued length:4];
        [stowData appendBytes:&count00020000  length:4];
        [stowData appendData:metainfoData];
        
        [stowData appendData:[NSMutableData DICMDataWithDICMDictionary:dicm bulkdataBaseURI:nil]];        

        [stowData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundaryString] dataUsingEncoding:NSASCIIStringEncoding]];
        
//request
        id request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:timeout];
        // https://developer.apple.com/reference/foundation/nsurlrequestcachepolicy?language=objc;
        //NSURLRequestReturnCacheDataElseLoad
        //NSURLRequestReloadIgnoringCacheData
        [request setHTTPMethod:@"POST"];
        [request setValue:[NSString stringWithFormat:@"multipart/related;type=application/dicom;boundary=%@",boundaryString] forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:stowData];
        return request;
    }
    return nil;
}

@end
