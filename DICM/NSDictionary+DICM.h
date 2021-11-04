//
//  NSDictionary+DICM.h
//  FoundationDICM2
//
//  Created by jacques on 20100828.
//  Copyright 2010 jacquesfauquex@gmail.com All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSDictionary(DICM)

//metadata (group 0002)
+(NSDictionary*)DICM0002ForMediaStorageSOPClassUID:(NSString*)mediaStorageSOPClassUID
                        mediaStorageSOPInstanceUID:(NSString*)mediaStorageSOPInstanceUID
                            implementationClassUID:(NSString*)implementationClassUID
                         implementationVersionName:(NSString*)implementationVersionName
                      sourceApplicationEntityTitle:(NSString*)sourceApplicationEntityTitle
                      privateInformationCreatorUID:(NSString*)privateInformationCreatorUID
                                privateInformation:(NSData*)privateInformation;

//----------------------
/*
// modules4iods

				SC	KOS	SP	HG	HC	SR	PDF	CDA
 PATIENT
				M	M		M	M		M	M	DICMC070101	Patient
				U	U		U	U		U	U	DICMC070103	Clinical Trial Subject
 STUDY
				M	M		M	M		M	M	DICMC070201	General Study
				U	U		U	U		U	U	DICMC070202	Patient Study
				U	U			U		U	U	DICMC070203	Clinical Trial Study
 SERIES
				M			M	M				DICMC070301 General Series
				U	U		U	U		U	U	DICMC070302	Clinical Trial Series
					M							DICMC170601	Key Object Document Series
                                        M   M   DICMC240100 Encapsulated Series 
 EQUIPMENT
				U	M		U	U		M	M	DICMC070501	General Equipment
							M	M				DICMC081001	Hardcopy Equipment
				M						M	M	DICMC080601	SC Equipment
 DOCUMENT
                M	M		M	M       M   M   DICMC120100	SOP Common
					M							DICMC170602 Key Object Document
                                        M   M   DICMC240200 Encapsulated Document
 IMAGE
				M			M	M				DICMC070601	General Image
				M								DICMC070603	Image Pixel
				U								DICMC070612	Device
				U								DICMC070622	Specimen
				M								DICMC080602	SC Image
							M					DICMC081002	HC Grayscale Image
								M				DICMC081003	HC Color Image
				U								DICMC090200	Overlay Plane
				U								DICMC110100	Modality LUT
				U								DICMC110200	VOI LUT

 */

//modules


//PATIENT
+(NSDictionary*)DICMC070101PatientWithName:(NSString*)name
                                       pid:(NSString*)pid
                                    issuer:(NSString*)issuer
                                 birthdate:(NSString*)DA
                                       sex:(NSString*)sex;

//STUDY
+(NSDictionary*)DICMC070201StudyWithUID:(NSString*)studyUID
                                     DA:(NSString*)DA
                                     TM:(NSString*)TM
                                     ID:(NSString*)ID
                                     AN:(NSString*)AN
                                 issuer:(NSString*)issuer
                                   name:(NSString*)name
                                   code:(NSString*)code
                                 scheme:(NSString*)scheme
                                meaning:(NSString*)meaning;//General Study


+(NSDictionary*)DICMC070202ForStudyObject:(NSManagedObject*)studyObject;//Patient Study


//SERIES
+(NSDictionary*)DICMC070301ForModality1:(NSString*)modality
                             seriesUID1:(NSString*)seriesUID
                          seriesNumber2:(NSString*)seriesNumber
                           laterality2c:(NSString*)laterality
                            seriesDate3:(NSDate*)seriesDate
                            seriesTime3:(NSDate*)seriesTime
              performingPhysiciansName3:(NSString*)performingPhysiciansName
                          protocolName3:(NSString*)protocolName
                     seriesDescription3:(NSString*)seriesDescription
                      bodyPartExamined3:(NSString*)bodyPartExamined
                      patientPosition2c:(NSString*)patientPosition
            smallestPixelValueInSeries3:(NSValue*)smallestPixelValueInSeries
             largestPixelValueInSeries3:(NSValue*)largestPixelValueInSeries;//General Series

+(NSDictionary*)DICMC070301ForModality1:(NSString*)modality
                             seriesUID1:(NSString*)seriesUID
                          seriesNumber2:(NSString*)seriesNumber
                     seriesDescription3:(NSString*)seriesDescription;//General Series

+(NSDictionary*)DICMC170601ForModality1:(NSString*)modality
                             seriesUID1:(NSString*)seriesUID
                          seriesNumber2:(NSString*)seriesNumber
                     seriesDescription3:(NSString*)seriesDescription;//key object document series

+(NSDictionary*)DICMC240100ForModality1:(NSString*)modality
                             seriesUID1:(NSString*)seriesUID
                          seriesNumber2:(NSString*)seriesNumber
                              seriesDA3:(NSString*)DA
                              seriesTM3:(NSString*)TM
                     seriesDescription3:(NSString*)seriesDescription;

//EQUIPMENT
+(NSDictionary*)DICMC070501;

+(NSDictionary*)DICMC081001;//Hardcopy Equipment

+(NSDictionary*)DICMC080601ForConversionType1:(NSString*)conversionType;//SC equipment 


/*
//IMAGE
+(NSDictionary*)DICMC070601ForDerivationDescription3:(NSString*)derivationDescription
                                sourceImageSequence3:(NSArray*)sourceImageSequence
                          spatialLocationsPreserved3:(NSString*)spatialLocationsPreserved
                                patientOrientation1c:(NSString*)patientOrientation
                                 burnedInAnnotation3:(NSString*)burnedInAnnotation
                                           imageDate:(NSDate*)imageDate;//General Image

+(NSDictionary*)DICMC070601ForDerivationDescription3:(NSString*)derivationDescription
                                sourceImageSequence3:(NSArray*)sourceImageSequence
                          spatialLocationsPreserved3:(NSString*)spatialLocationsPreserved
                                patientOrientation1c:(NSString*)patientOrientation
                                 burnedInAnnotation3:(NSString*)burnedInAnnotation;

//(NSDictionary*)DICMC070603 -> NSBitmapImageRep_DICM

+(NSDictionary*)DICMC080602ForNominalScannedPixelSpacing3:(NSString*)nominalScannedPixelSpacing
                                           pixelSpacing1c:(NSString*)pixelSpacing;//SC Image
*/

//DOCUMENT
+(NSDictionary*)DICMC170602ForUIDUIDUIDStrings1:(NSArray*)UIDUIDUIDStrings;//key object document

+(NSDictionary*)DICMC240200EncapsulatedCDAWithDA:(NSString*)DA
                                              TM:(NSString*)TM
                                           title:(NSString*)title
                                           HL7II:(NSString*)HL7II
                                            data:(NSData*)data;

//COMMON
+(NSDictionary*)DICMC120100ForSOPClassUID1:(NSString*)SOPClassUID
                           SOPInstanceUID1:(NSString*)SOPInstanceUID
                                  charset1:(NSString*)charset
                                       DA1:(NSString*)DA
                                       TM1:(NSString*)TM
                                        TZ:(NSString*)TZ;

@end
