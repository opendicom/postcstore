//
//  NSDictionary+DICM.m
//  FoundationDICM2
//
//  Created by jacques on 20100828.
//  Copyright 2010 jacquesfauquex@gmail.com All rights reserved.
//

#import "NSDictionary+DICM.h"
#import "NSMutableDictionary+DICM.h"
#import "printfLog.h"

@implementation NSDictionary(DICM)

static unsigned short  kDICM		= 0x0100;


static char			   CID7202[]	= { 
	0xFE,0xFF,0x00,0xE0,0xFF,0xFF,0xFF,0xFF,
	0x08,0x00,0x00,0x01,0x53,0x48,0x06,0x00,0x31,0x32,0x31,0x33,0x32,0x39,
	0x08,0x00,0x02,0x01,0x53,0x48,0x04,0x00,0x44,0x43,0x4D,0x20,
	0x08,0x00,0x04,0x01,0x4C,0x4F,0x18,0x00,0x53,0x6F,0x75,0x72,0x63,0x65,0x20,0x69,0x6D,0x61,0x67,0x65,0x20,0x66,0x6F,0x72,0x20,0x6D,0x6F,0x6E,0x74,0x61,0x67,0x65,
	0xFE,0xFF,0x0D,0xE0,0x00,0x00,0x00,0x00,
};	



//used to decode SOP Instance UID
static inline unsigned char intToChar( int c)
{
	switch( c)
	{
		case 0:		return 0;		break;
		case 1:		return '0';		break;
		case 2:		return '1';		break;
		case 3:		return '2';		break;
		case 4:		return '3';		break;
		case 5:		return '4';		break;
		case 6:		return '5';		break;
		case 7:		return '6';		break;
		case 8:		return '7';		break;
		case 9:		return '8';		break;
		case 10:	return '9';		break;
		case 11:	return '.';		break;
	}
	
	return '0';
}


//----------------------------------------------------------------------
#pragma mark -
#pragma mark DICM metadata

+(NSDictionary*)DICM0002ForMediaStorageSOPClassUID:(NSString*)mediaStorageSOPClassUID
                        mediaStorageSOPInstanceUID:(NSString*)mediaStorageSOPInstanceUID
                            implementationClassUID:(NSString*)implementationClassUID
                         implementationVersionName:(NSString*)implementationVersionName
                      sourceApplicationEntityTitle:(NSString*)sourceApplicationEntityTitle
                      privateInformationCreatorUID:(NSString*)privateInformationCreatorUID
                                privateInformation:(NSData*)privateInformation
{
	//SOPClassUID
	//HG	Hardcopy Grayscale		@"1.2.840.10008.5.1.1.29"
	//HC	Hardcopy Color			@"1.2.840.10008.5.1.1.30"
	//SC	Secondary Capture		@"1.2.840.10008.5.1.4.1.1.7"
	//SR	Basic Structured Report	@"1.2.840.10008.5.1.4.1.1.88.11"
	//KO	Key Object Selection	@"1.2.840.10008.5.1.4.1.1.88.59"
	//PDF	PDF						@"1.2.840.10008.5.1.4.1.1.104.1"
	//CDA	CDA						@"1.2.840.10008.5.1.4.1.1.104.2"
	

	NSMutableDictionary *DICM0002 = [NSMutableDictionary dictionaryWithCapacity:9];
	
	[DICM0002 setDICMData:[NSData dataWithBytes:&kDICM length:2]	forKey:@"00020001OB"];//FileMetaInformationVersion
	[DICM0002 setDICMString:mediaStorageSOPClassUID					forKey:@"00020002UI"];
	[DICM0002 setDICMString:mediaStorageSOPInstanceUID				forKey:@"00020003UI"];
	[DICM0002 setDICMString:@"1.2.840.10008.1.2.1"					forKey:@"00020010UI"];//TransferSyntaxUID
	[DICM0002 setDICMString:implementationClassUID					forKey:@"00020012UI"];//ImplementationClassUID
	[DICM0002 setDICMString:implementationVersionName				forKey:@"00020013SH"];//ImplementationVersionName
	[DICM0002 setDICMString:sourceApplicationEntityTitle			forKey:@"00020016AE"];//SourceApplicationEntityTitle
	//[DICM0002 setDICMString:privateInformationCreatorUID			forKey:@"00020100UI"];//3
	//[DICM0002 setDICMData:privateInformation						forKey:@"00020102OB"];//1c
	return [NSDictionary dictionaryWithDictionary:DICM0002];
}


//----------------------------------------------------------------------
#pragma mark -
#pragma mark DICM 3.3 Annex C modules PATIENT


+(NSDictionary*)DICMC070101PatientWithName:(NSString*)name
                                       pid:(NSString*)pid
                                    issuer:(NSString*)issuer
                                 birthdate:(NSString*)DA
                                       sex:(NSString*)sex
{
    //=======
    //Patient
    //=======
    
    NSMutableDictionary *DICMC070101 = [NSMutableDictionary dictionaryWithCapacity:11];
    
    [DICMC070101 setDICMString:name    forKey:@"00100010PN"];//PatientName
    [DICMC070101 setDICMString:pid     forKey:@"00100020LO"];//PatientID
    [DICMC070101 setDICMString:issuer  forKey:@"00100021LO"];//issuer Macro Table 10-18
    [DICMC070101 setDICMString:DA forKey:@"00100030DA"];//PatientBirthDate
    [DICMC070101 setDICMString:sex  forKey:@"00100040CS"];//PatientSex
    
    //00101000 Other Patient IDs
    //00101002 Other Patient IDs Sequence
    //>00100020 Patient ID
    //>Include Issuer of Patient ID Macro Table 10-18
    //>00100022 Type of Patient ID [TEXT|RFID|BARCODE]
    //00102297 Responsible Person
    //00102298 Responsible Person Role
    //00102299 Responsible Organization
    
    //[DICMC070101 setDICMString:@"" forKey:@"00102160SH"];//EthnicGroup
    //[DICMC070101 setDICMString:@"" forKey:@"00104000LT"];//PatientComments
    
    //00120062 Patient identity Removed
    //00120063 De-identification Method
    //00120064 De-identification Method Code Sequence
    //>Include Code Sequence Macro Table 8.8-1
    
    return [NSDictionary dictionaryWithDictionary:DICMC070101];
}

//----------------------------------------------------------------------
#pragma mark -
#pragma mark DICM 3.3 Annex C modules STUDY

+(NSDictionary*)DICMC070201StudyWithUID:(NSString*)studyUID
                                     DA:(NSString*)DA
                                     TM:(NSString*)TM
                                     ID:(NSString*)ID
                                     AN:(NSString*)AN
                                 issuer:(NSString*)issuer
                                   name:(NSString*)name
                                   code:(NSString*)code
                                 scheme:(NSString*)scheme
                                meaning:(NSString*)meaning
{
	//=============
	//General Study
	//=============
	
	NSMutableDictionary *DICMC070201 = [NSMutableDictionary dictionaryWithCapacity:11];

	[DICMC070201 setDICMString:studyUID	forKey:@"0020000DUI"];//StudyInstanceUID
	[DICMC070201 setDICMString:DA	forKey:@"00080020DA"];//StudyDate 2
	[DICMC070201 setDICMString:TM forKey:@"00080030TM"];//StudyTime 2
	[DICMC070201 setDICMString:@""	forKey:@"00080090PN"];//ReferringPhysicianName 2

	//00080096 Referring Physician Identification Sequence
	//>Include 'Person Identification Macro' Table 10-1
	
	[DICMC070201 setDICMString:ID forKey:@"00200010SH"];//StudyID 2
	[DICMC070201 setDICMString:AN forKey:@"00080050SH"];//AccessionNumber 2
	
	//00080051 Issuer of Accession Number Sequence
	//>Include HL7v2 Hierarchic Designator Macro Table 10-17
	
	[DICMC070201 setDICMString:name forKey:@"00081030LO"];//StudyDescription 3
    
    [DICMC070201 setCodeSequenceForKey:@"00081032SQ"
                                  code:code
                                scheme:scheme
                               meaning:meaning];//00081032 Procedure Code Sequence

	//[DICMC070201 setDICMString:@"" forKey:@"00081060PN"];//NameOfPhysiciansReadingStudy

	//00080096 Physician(s) Reading Study Identification Sequence
	//>Include 'Person Identification Macro' Table 10-1
	
	//00321034 Requesting Service Code Sequence
	//Include 'Code Sequence Macro' Table 10-1
	
	//00081110 Referenced Study Sequence
	//>Include SOP Instance Reference Macro Table 10-11
	
	//00401012 Reason For Performed Procedure Code Sequence
	//>Include 'Code Sequence Macro' Table 8.8-1
	
	return [NSDictionary dictionaryWithDictionary:DICMC070201];
}

//----------------------------------------------------------------------

+(NSDictionary*)DICMC070202ForStudyObject:(NSManagedObject*)studyObject
{
	//=============
	//Patient Study
	//=============
	
	NSMutableDictionary *DICMC070202 = [NSMutableDictionary dictionaryWithCapacity:11];
		
	//[DICMC070202 setDICMString:@"" forKey:@"00081080LO"];//AdmittingDiagnosesDescription
	//00081084 Admitting Diagnoses Code Sequence
	//Include 'Code Sequence Macro' Table 8.8-1
	
	NSString *age;
	if( [studyObject valueForKey: @"dateOfBirth"])
	{
		NSCalendarDate *birthdate = [NSCalendarDate dateWithTimeIntervalSinceReferenceDate: [[studyObject valueForKey:@"dateOfBirth"] timeIntervalSinceReferenceDate]];
		NSCalendarDate *studyDate = [NSCalendarDate dateWithTimeIntervalSinceReferenceDate: [[studyObject valueForKey:@"date"] timeIntervalSinceReferenceDate]];		
		NSInteger years, months, days;
		
		[studyDate years:&years months:&months days:&days hours:NULL minutes:NULL seconds:NULL sinceDate:birthdate];
		
		if( years < 2)
		{
			if( years < 1)
			{
				if( months < 1) age = [NSString stringWithFormat: @"%03ldD", (long)days];
				else if (months < 4 )age =  [NSString stringWithFormat: @"%03ldW", (days / 7)];
				else age = [NSString stringWithFormat: @"%03ldM", (long)months];
			}
			else age = [NSString stringWithFormat: @"%03ldM", (long)months];
		}
		else age = [NSString stringWithFormat: @"%03ldY", (long)years];
	}
	else age = @"????";
	
	
	[DICMC070202 setDICMString:age forKey:@"00101010AS"];//PatientAge
	//[DICMC070202 setDICMString:@"" forKey:@"00101020DS"];//PatientSize
	//[DICMC070202 setDICMString:@"" forKey:@"00101030DS"];//PatientWeight
	//[DICMC070202 setDICMString:@"" forKey:@"00102180SH"];//Occupation
	//[DICMC070202 setDICMString:@"" forKey:@"001021B0LT"];//AdditionalPatientHistory

	return [NSDictionary dictionaryWithDictionary:DICMC070202];
}


//----------------------------------------------------------------------
#pragma mark -
#pragma mark DICM 3.3 Annex C modules SERIES

+(NSDictionary*)DICMC070301ForModality1:(NSString*)modality seriesUID1:(NSString*)seriesUID seriesNumber2:(NSString*)seriesNumber laterality2c:(NSString*)laterality seriesDate3:(NSDate*)seriesDate seriesTime3:(NSDate*)seriesTime performingPhysiciansName3:(NSString*)performingPhysiciansName protocolName3:(NSString*)protocolName seriesDescription3:(NSString*)seriesDescription bodyPartExamined3:(NSString*)bodyPartExamined patientPosition2c:(NSString*)patientPosition smallestPixelValueInSeries3:(NSValue*)smallestPixelValueInSeries largestPixelValueInSeries3:(NSValue*)largestPixelValueInSeries
{
	//==============
	//General Series
	//==============
	
	NSMutableDictionary *DICMC070301 = [NSMutableDictionary dictionaryWithCapacity:11];
	
	//1
	if (!modality)							{ printfLog(@"ERROR -> [NSDictionary] DICMC070301 modality 1 nil"); return nil;}
	if ([modality isEqualToString:@""])		{ printfLog(@"ERROR -> [NSDictionary] DICMC070301 modality 1 empty"); return nil;}
	[DICMC070301 setDICMString:modality	forKey:@"00080060CS"];
	
	//1
	if (!seriesUID)							{ printfLog(@"ERROR -> [NSDictionary] DICMC070301 seriesUID 1 nil"); return nil;}
	if ([seriesUID isEqualToString:@""])	{ printfLog(@"ERROR -> [NSDictionary] DICMC070301 seriesUID 1 empty"); return nil;}
	[DICMC070301 setDICMString:seriesUID forKey:@"0020000EUI"];
	
	//2
	if (!seriesNumber)						{ printfLog(@"ERROR -> [NSDictionary] DICMC070301 seriesNumber 2 nil"); return nil;}
	[DICMC070301 setDICMString:seriesNumber	forKey:@"00200011IS"];
	
	//2C presentWhenPairedExtremities
	if (laterality) [DICMC070301 setDICMString:laterality forKey:@"00200060CS"];//[R|L]
	
	//3
	if (seriesDate) [DICMC070301 setDICMString:seriesDate	forKey:@"00080021DA"];
	
	//3
	if (seriesTime)	[DICMC070301 setDICMString:seriesTime	forKey:@"00080031TM"];
					 
	//3
	if (performingPhysiciansName) [DICMC070301 setDICMString:performingPhysiciansName forKey:@"00081050PN"];

	//3
	if (protocolName) [DICMC070301 setDICMString:protocolName forKey:@"00181030LO"];

	//3
	if (seriesDescription) [DICMC070301 setDICMString:seriesDescription	forKey:@"0008103ELO"];
	
	//3
	if (bodyPartExamined) [DICMC070301 setDICMString:bodyPartExamined forKey:@"00180015CS"];
					 
	//2c
	if (patientPosition) [DICMC070301 setDICMString:patientPosition forKey:@"00185100CS"];
					 
	//3
	if (smallestPixelValueInSeries) [DICMC070301 setDICMValue:smallestPixelValueInSeries forKey:@"00280108"];//SS o US
					 
	//3
	if (largestPixelValueInSeries) [DICMC070301 setDICMValue:largestPixelValueInSeries forKey:@"00280109"];//SS o US
	
	return [NSDictionary dictionaryWithDictionary:DICMC070301];

	//00081052 3	PerformingPhysicianIdentificationSequence
	//>Include 'Person Identification Macro' Table 10-1
	//0008103E Series Description Code Sequence
	//>Include Code Sequence Macro Table 8.8-1
	//00081070	3	Operator's Name
	//00081072	3	OperatorIdentificationSequence
	//>Include 'Person Identification Macro' Table 10-1
	//00081111	3	Referenced Performed Procedure Step Sequence
	//>Include SOP Instance reference Macro Table 10-10
	//00081250	3	Related Series Sequence
	//>0020000D	1	Study Instance UID
	//>0020000E	1	Series Instance UID
	//>0040A170	2	Purpose of Reference Code Sequence
	//>>Include Code Sequence macro Table 8.8-1 Defined CID 7210
	//00400275	3	Request Attributes Sequence
	//>Include Request Attributes Macro Table 10-9
	//Include Performed Procedure Step Summary Macro Table 10-16
	//0010,2210	1C	Anatomical Orientation Type [BIPED|QUADRUPED]					 
}

+(NSDictionary*)DICMC070301ForModality1:(NSString*)modality
                             seriesUID1:(NSString*)seriesUID
                          seriesNumber2:(NSString*)seriesNumber
                     seriesDescription3:(NSString*)seriesDescription
{
	return [self DICMC070301ForModality1:modality 
							  seriesUID1:seriesUID 
						   seriesNumber2:seriesNumber 
							laterality2c:@"" 
							 seriesDate3:[NSDate date]
							 seriesTime3:[NSDate date] 
			   performingPhysiciansName3:nil
						   protocolName3:nil 
					  seriesDescription3:seriesDescription 
					   bodyPartExamined3:nil 
					   patientPosition2c:nil 
		     smallestPixelValueInSeries3:nil 
			  largestPixelValueInSeries3:nil
			];
}

+(NSDictionary*)DICMC240100ForModality1:(NSString*)modality
                             seriesUID1:(NSString*)seriesUID
                          seriesNumber2:(NSString*)seriesNumber
                              seriesDA3:(NSString*)DA
                              seriesTM3:(NSString*)TM
                     seriesDescription3:(NSString*)seriesDescription
{
    //==============
    //General Series
    //==============
    
    NSMutableDictionary *DICMC240100 = [NSMutableDictionary dictionaryWithCapacity:11];
    
    [DICMC240100 setDICMString:modality forKey:@"00080060CS"];//1
    [DICMC240100 setDICMString:seriesUID forKey:@"0020000EUI"];//1
    
    [DICMC240100 setDICMString:seriesNumber forKey:@"00200011IS"];//2
    [DICMC240100 setDICMString:DA forKey:@"00080021DA"];//3
    [DICMC240100 setDICMString:TM forKey:@"00080031TM"];//3
    [DICMC240100 setDICMString:seriesDescription forKey:@"0008103ELO"];//3
    return [NSDictionary dictionaryWithDictionary:DICMC240100];
}

//----------------------------------------------------------------------

+(NSDictionary*)DICMC170601ForModality1:(NSString*)modality 
                             seriesUID1:(NSString*)seriesUID
                          seriesNumber2:(NSString*)seriesNumber
                     seriesDescription3:(NSString*)seriesDescription
{
	//============================================
	//KEY OBJECT DOCUMENT SERIES MODULE ATTRIBUTES
	//============================================
	
	NSMutableDictionary *DICMC170601 = [NSMutableDictionary dictionaryWithCapacity:11];
	
	[DICMC170601 setDICMString:modality				forKey:@"00080060CS"];//Modality
	[DICMC170601 setDICMString:seriesUID			forKey:@"0020000EUI"];//SeriesInstanceUID
	[DICMC170601 setDICMString:seriesNumber			forKey:@"00200011IS"];//SeriesNumber
	[DICMC170601 setDICMString:[NSDate date]		forKey:@"00080021DA"];//InstanceCreationDate
	[DICMC170601 setDICMString:[NSDate date]		forKey:@"00080031TM"];//InstanceCreationTime
	[DICMC170601 setDICMString:seriesDescription	forKey:@"0008103ELO"];//SeriesDescription
	
	//0008103F Series Description Code Sequence
	//>Include Code Sequence Macro Table 8.8-1
	
	//Referenced Performed Procedure Step Sequence
	//>Include 'SOP Instance Reference Macro' Table 10-11
	[DICMC170601 setDICMSQForKey:@"00081111SQ"];
	
	return [NSDictionary dictionaryWithDictionary:DICMC170601];
}

//----------------------------------------------------------------------

#pragma mark -
#pragma mark DICM 3.3 Annex C modules EQUIPMENT

+(NSDictionary*)DICMC070501
{
	//===================================
	//GENERAL EQUIPMENT MODULE ATTRIBUTES
	//===================================
	
	NSMutableDictionary *DICMC070501 = [NSMutableDictionary dictionaryWithCapacity:6];
	
	//2
    [DICMC070501 setDICMString:@"OPENDICOM Jesros S.A., URUGUAY"	forKey:@"00080070LO"];//Manufacturer
	
	//3
	//NSString *institutionName = [studyObject valueForKeyPath:@"institutionName"];
	//if (institutionName) [DICMC070501 setDICMString:institutionName	forKey:@"00080080LO"];//InstitutionName

	//3
	//00080081 Institution Address
	
	//3
	//00081010 Station Name
	
	//3
	//00081040 Institutional Department Name
	
	//3
	//[DICMC070501 setDICMString:@"_DICM" forKey:@"00081090LO"];//Manufacturer's Model Name

	//3
	//[DICMC070501 setDICMString:[[FoundationDICM sharedManager]serialAlpha]	forKey:@"00181000LO"];//Device Serial Number
	
	//3
	//[DICMC070501 setDICMString:@"0.9" forKey:@"00181020LO"];//Software Versions
	
	//00181008	3	Gantry ID
	//00181050	3	Spatial Resolution
	//00181200	3	Date of Last Calibration
	//00181201	3	Time of Last Calibration
	
	//1c
	//if (pixelPaddingValue) [DICMC070501 setDICMValue:pixelPaddingValue forKey:@"00280120"];//Pixel Padding Value
	
	return [NSDictionary dictionaryWithDictionary:DICMC070501];
}

//----------------------------------------------------------------------


+(NSDictionary*)DICMC081001
{
	//==================
	//hardcopy equipment
	//==================

	NSMutableDictionary *DICMC081001 = [NSMutableDictionary dictionaryWithCapacity:5];
	
	//1
	[DICMC081001 setDICMString:@"HC" forKey:@"00080060CS"];//Modality
	

	return [NSDictionary dictionaryWithDictionary:DICMC081001];

}

//----------------------------------------------------------------------

+(NSDictionary*)DICMC080601ForConversionType1:(NSString*)conversionType
{
	//============
	//SC equipment
	//============
	
	NSMutableDictionary *DICMC080601 = [NSMutableDictionary dictionaryWithCapacity:6];
	
	//1
	if (!conversionType)					{ printfLog(@"ERROR -> [NSDictionary] DICMC080601 Conversion Type 1 nil"); return nil;}
	if ([conversionType isEqualToString:@"DV"]  ||//Digitized Video
		[conversionType isEqualToString:@"DI"]  ||//Digital Interface
		[conversionType isEqualToString:@"DF"]  ||//Digitized Film
		[conversionType isEqualToString:@"WSD"] ||//Workstation
		[conversionType isEqualToString:@"SD"]  ||//Scanned Document
		[conversionType isEqualToString:@"SI"]  ||//Scanned Image
		[conversionType isEqualToString:@"DRW"] ||//Drawing
		[conversionType isEqualToString:@"SYN"]   //Synthetic Image
		) [DICMC080601 setDICMString:conversionType forKey:@"00080064CS"];
	else { printfLog(@"ERROR -> [NSDictionary] DICMC070301 Conversion Type 1 not standard:%@",conversionType); return nil;}
	
	//3
	//already present in series
	//[DICMC080601 setDICMString:@"OT" forKey:@"00080060.CS"];//Modality
	
	//3
	//[DICMC080601 setDICMString:[[FoundationDICM sharedManager]serialAlpha] forKey:@"00181010LO"];//Secondary Capture Device ID
	
	//3
	[DICMC080601 setDICMString:@"OPENDICOM" forKey:@"00181016LO"];//Secondary Capture Device Manufacturer
	
	//not included in standard
	[DICMC080601 setDICMString:@"OPENDICOM"	forKey:@"00080070LO"];//Manufacturer
	
	//3
	//[DICMC080601 setDICMString:@"PAGES" forKey:@"00181018LO"];//Secondary Capture Device Manufacturer's Model Name
	
	//3
	//[DICMC080601 setDICMString:"0.9" forKey:@"00181019LO"];//Hardcopy Device Software Versions

	//3
	//00181022 Video Image Format Acquired
	
	//3
	//00181023 Digital Image Format Acquired
	
	return [NSDictionary dictionaryWithDictionary:DICMC080601];
	
}


//----------------------------------------------------------------------
#pragma mark -
#pragma mark DICM 3.3 Annex C modules IMAGE
/*
+(NSDictionary*)DICMC070601ForDerivationDescription3:(NSString*)derivationDescription
                                sourceImageSequence3:(NSArray*)sourceImageSequence
                          spatialLocationsPreserved3:(NSString*)spatialLocationsPreserved
                                patientOrientation1c:(NSString*)patientOrientation
                                 burnedInAnnotation3:(NSString*)burnedInAnnotation
{
	//if imageDate is nil, image acquisition date and time are not added in DICM070601
	return [self DICMC070601ForDerivationDescription3:derivationDescription
                                 sourceImageSequence3:sourceImageSequence
                           spatialLocationsPreserved3:spatialLocationsPreserved
                                 patientOrientation1c:patientOrientation
                                  burnedInAnnotation3:burnedInAnnotation
                                            imageDate:[NSDate date]];
}


+(NSDictionary*)DICMC070601ForDerivationDescription3:(NSString*)derivationDescription
                                sourceImageSequence3:(NSArray*)sourceImageSequence
                          spatialLocationsPreserved3:(NSString*)spatialLocationsPreserved
                                patientOrientation1c:(NSString*)patientOrientation
                                 burnedInAnnotation3:(NSString*)burnedInAnnotation
                                           imageDate:(NSDate*)imageDate
{
	//=============
	//General Image
	//=============
	
	NSMutableDictionary *DICMC070601 = [NSMutableDictionary dictionaryWithCapacity:11];

	//2
	[DICMC070601 setDICMString:[[NSDate date] descriptionWithCalendarFormat:@"%H%M%S" timeZone:nil locale:nil]	forKey:@"00200013IS"];//InstanceNumber

	//2c
	if (patientOrientation) [DICMC070601 setDICMString:patientOrientation forKey:@"00200020CS"];//PatientOrientation (left to right + top to bottom)[A|P|R|L|H|F]
	else  [DICMC070601 setDICMString:@"" forKey:@"00200020CS"];
	//2c
	[DICMC070601 setDICMString:imageDate forKey:@"00080023DA"];//Content Date
	[DICMC070601 setDICMString:imageDate forKey:@"00080033TM"];//Content Time
	
	//00080008	3	Image Type
	//00200012	3	Acquisition Number
	if (imageDate!=nil)
	{
		[DICMC070601 setDICMString:imageDate forKey:@"00080022DA"];//Acquisition Date
		[DICMC070601 setDICMString:imageDate forKey:@"00080032TM"];//Acquisition Time
		[DICMC070601 setDICMString:imageDate forKey:@"0008002ADT"];//Acquisition DateTime
	}
	//00081140	3	Referenced Image Sequence
	//>Include 'Image SOP Instance Reference Macro' Table 10-3
	//>0040A170	Purpose of Reference Code Sequence
	//>>Include 'Code Sequence Macro' Table 8.8-1
	
	//Derivation Description & 
	//Source Image Sequence &
	//Image Comments
	//3
	if (derivationDescription) [DICMC070601 setDICMString:derivationDescription forKey:@"00082111ST"];//DerivationDescription
	
	//3
	//00089215	3	Derivation Code Sequence
	//>Include 'Code Sequence Macro' Table 8.8-1
	
	//3
	if (sourceImageSequence)
	{
		[DICMC070601 setObject:[NSArray array] forKey:@"00082112.00000000"];//SourceImageSequence
		NSUInteger sourceImageIndex = 0;
		NSMutableString *imageComments = [NSMutableString stringWithCapacity:200];//00204000
		for (NSManagedObject *sourceImage in sourceImageSequence)
		{
            //================================
#pragma mark TODO investigate why %0000d doesn't work anymore
            //================================
            
			//item beginning
			sourceImageIndex++;
            NSString *sourceImageIndexString=[NSString stringWithFormat:@"%lu",sourceImageIndex];
            NSUInteger sourceImageIndexStringCount = [sourceImageIndexString length];
            NSMutableString *zeros=[NSMutableString stringWithString:@"00000000"];
            [zeros replaceCharactersInRange:NSMakeRange(8 - sourceImageIndexStringCount,sourceImageIndexStringCount) withString:sourceImageIndexString];
			NSString *elementTag = [NSString stringWithFormat:@"00082112.%@",zeros];
            //printfLog(@"%@",elementTag);
			[DICMC070601 setObject:[NSArray array] forKey:elementTag];
			
			[DICMC070601 setDICMString:[sourceImage valueForKeyPath:@"series.seriesSOPClassUID"] forKey:[NSString stringWithFormat:@"%@/00081150.UI",elementTag]];
			
			NSData *compressedData = [sourceImage primitiveValueForKey:@"compressedSopInstanceUID"];
			unsigned char* src =  (unsigned char*) [compressedData bytes];
			unsigned int   i, x;
			char str[ 64];
			for( i = 0, x = 0; i < [compressedData length]; i++) {
				str[x++] = intToChar( (int)(src[ i] >> 4));
				str[x++] = intToChar( (int)(src[ i] & 15));}
			str[x] = '\0';	
			[DICMC070601 setDICMString:[NSString stringWithCString:str encoding:NSASCIIStringEncoding] forKey:[NSString stringWithFormat:@"%@/00081155UI",elementTag]];
			
			int referencedFrameNumber= [[sourceImage valueForKeyPath:@"frameID"]intValue];
			if ((!referencedFrameNumber) || (referencedFrameNumber == 0)) referencedFrameNumber = 1;
			[DICMC070601 setDICMString:[NSString stringWithFormat:@"%d",referencedFrameNumber] forKey:[NSString stringWithFormat:@"%@/00081160.IS",elementTag]];
			
			//3
			[DICMC070601 setObject:[NSArray arrayWithObject:[NSData dataWithBytes:&CID7202 length:74]] forKey:[NSString stringWithFormat:@"%@/0040A170.SB",elementTag]];//SP SB
			
			//3
			if (spatialLocationsPreserved)
			{
				if		([spatialLocationsPreserved isEqualToString:@"YES"] || 
						 [spatialLocationsPreserved isEqualToString:@"NO"])	[DICMC070601 setDICMString:spatialLocationsPreserved forKey:[NSString stringWithFormat:@"%@/0028135A.CS",elementTag]];					
				else if ([spatialLocationsPreserved isEqualToString:@"REORIENTED_ONLY"])
				{
					//1c
					if (patientOrientation) 
					{
						[DICMC070601 setDICMString:spatialLocationsPreserved forKey:[NSString stringWithFormat:@"%@/0028135A.CS",elementTag]];					
						[DICMC070601 setDICMString:patientOrientation forKey:[NSString stringWithFormat:@"%@/00200020.CS",elementTag]];
					}
					else printfLog(@"ERROR -> [DICMC070601] Spatial Location Preserved requires (0020,0020) Patient Orientation, which is missing");
				}
				else printfLog(@"ERROR -> [DICMC070601] Spatial Location Preserved mismatch [YES|NO|REORIENTED_ONLY]:%@",spatialLocationsPreserved);
			}		
			[DICMC070601 setObject:[NSArray array] forKey:[NSString stringWithFormat:@"%@/FFFEE00D.OD",elementTag]];
			
			NSString *comment  = [sourceImage valueForKeyPath:@"comment" ];
			NSString *comment2 = [sourceImage valueForKeyPath:@"comment2"];
			NSString *comment3 = [sourceImage valueForKeyPath:@"comment3"];
			NSString *comment4 = [sourceImage valueForKeyPath:@"comment4"];
			if(comment ) [imageComments appendFormat:@"%@\r",comment ];
			if(comment2) [imageComments appendFormat:@"%@\r",comment2];
			if(comment3) [imageComments appendFormat:@"%@\r",comment3];
			if(comment4) [imageComments appendFormat:@"%@\r",comment4];
		}
		[DICMC070601 setObject:[NSArray array] forKey:@"00082112DD"];
		
		//3
		//images derived copy the comments of the files there where derived from
		if (![imageComments isEqualToString:@""]) [DICMC070601 setDICMString:imageComments forKey:@"00204000LT"];
	}
	
	//0008114A	3	Referenced Instance Sequence
	//>Include SOP Instance Reference Macro Table 10-11
	//>0040A170	1	Purpose of Reference Code Sequence
	//>>Include 'Code Sequence Macro' Table 8.8-1
	
	//00201002	3	Images in Acquisition
	
	//00280300	3	Quality Control Image
	
	//3
	if (burnedInAnnotation) 
	{
		if ([burnedInAnnotation isEqualToString:@"YES"] ||
			[burnedInAnnotation isEqualToString:@"NO"]
			) [DICMC070601 setDICMString:burnedInAnnotation forKey:@"00280301CS"];
		else printfLog(@"ERROR -> [DICMC070601] Burned In Annotation mismatch [YES|NO]:%@",burnedInAnnotation);
	}
	
	//00282110	3	Lossy Image Compression [00=notLossy|01=lossy]
	//00282112	3	Lossy Image Compression Ratio
	//00282114	3	Lossy Image Compression Method
	//00880200	3	Icon Image Sequence
	//>Include 'Image Pixel Macro' Table C.7-11b
	//20500020	3	Presentation LUT Shape [IDENTITY|INVERSE]
	//00083010	3	Irradiation Event UID
        
	return [NSDictionary dictionaryWithDictionary:DICMC070601];
}


//----------------------------------------------------------------------

+(NSDictionary*)DICMC080602ForNominalScannedPixelSpacing3:(NSString*)nominalScannedPixelSpacing
                                           pixelSpacing1c:(NSString*)pixelSpacing
{
	//========
	//SC Image
	//========
	
	NSMutableDictionary *DICMC080602 = [NSMutableDictionary dictionaryWithCapacity:11];
	
	NSDate *imageDate = [NSDate date];
	
	//3
	[DICMC080602 setDICMString:imageDate forKey:@"00181012DA"];//Date of Secondary Capture
	
	//3
	[DICMC080602 setDICMString:imageDate forKey:@"00181014TM"];//Time of Secondary Capture
	
	//3	DS2
	if (nominalScannedPixelSpacing) [DICMC080602 setDICMString:nominalScannedPixelSpacing forKey:@"00182010DS"];//NominalScannedPixelSpacing
	
	//1c DS2
	[DICMC080602 setDICMString:pixelSpacing forKey:@"00280030DS"];//PixelSpacing
	//00280A02	3	PixelSpacingCalibrationType
	//00280A04	1c	PixelSpacingCalibrationDescription
	
	return [NSDictionary dictionaryWithDictionary:DICMC080602];
	
}
*/

//----------------------------------------------------------------------
#pragma mark -
#pragma mark DICM 3.3 Annex C modules DOCUMENT
/*
+(NSDictionary*)DICMC170602ForUIDUIDUIDStrings1:(NSArray*)UIDUIDUIDStrings
{
	//The array is formed of String which follow this model:
	//_2.25.107659813395675218242762.321332925864455&seriesUID=1.3.6.1.4.1.23650.10.25.107659813395675218242762321332925864455&objectUID=1.3.6.1.4.1.23650.1515417280844112000.69706315306852490587
	//starts with _ instead of studyUID= in order not to overflow file name
	//dividing the string with the occurrence of & allow to classify the array by components and subcomponents
	
	//=====================================
	//KEY OBJECT DOCUMENT MODULE ATTRIBUTES
	//=====================================
	
	NSMutableDictionary *DICMC170602 = [NSMutableDictionary dictionaryWithCapacity:11];
	
	if (!UIDUIDUIDStrings) printfLog(@"ERROR -> [Dictionary_DICM] DICMC170602ForUIDUIDUIDStrings1 array nil");
	else
	{
		NSInteger UIDUIDUIDcount = [UIDUIDUIDStrings count];
		//if (UIDUIDUIDcount == 0) printfLog(@"ERROR -> [Dictionary_DICOM] DICMC170602ForUIDUIDUIDStrings1 array empty");
		//else 
		//{
			NSDate *contentDate = [NSDate date];
			[DICMC170602 setDICMString:[contentDate descriptionWithCalendarFormat:@"%H%M%S" timeZone:nil locale:nil]	forKey:@"00200013IS"];//InstanceNumber
			[DICMC170602 setDICMString:contentDate																	forKey:@"00080023DA"];//ContentDate
			[DICMC170602 setDICMString:contentDate																	forKey:@"00080033TM"];//ContentTime

			//0040A370 Referenced Request Sequenc
			NSMutableArray *studyUIDs = [NSMutableArray arrayWithCapacity:UIDUIDUIDcount];
			NSMutableArray *seriesUIDs = [NSMutableArray arrayWithCapacity:UIDUIDUIDcount];
			NSMutableArray *objectUIDs = [NSMutableArray arrayWithCapacity:UIDUIDUIDcount];
			//=%@&seriesUID=%@&
			for (NSString *UIDUIDUIDString in UIDUIDUIDStrings)
			{
				NSArray *SSO = [UIDUIDUIDString componentsSeparatedByString:@"&"];//SSO=Study Series Objetc
				[studyUIDs   addObject:[[SSO objectAtIndex:0]substringFromIndex:1]];
				[seriesUIDs  addObject:[[SSO objectAtIndex:1]substringFromIndex:10]];
				[objectUIDs addObject:[[SSO objectAtIndex:2]substringFromIndex:10]];
			}
			
			//------------- currentRequest --------------
						
			//0040A375	1 CurrentRequestedProcedureEvidenceSequence
			NSString *refStudySQ = [DICMC170602 setDICMSQForKey:@"0040A375SQ"];

			
			//define study list
			NSSet *studyUIDSet =[NSSet setWithArray:studyUIDs];
			
			BOOL multiStudy = ([studyUIDSet count] > 1);			
			NSString *equalStudySQ = nil;//0040A525 3c IdenticalDocumentsSequence
			if (multiStudy) equalStudySQ = [DICMC170602 setDICMSQForKey:@"0040A525SQ"];
			
			
			NSUInteger studyItemCounter = 1;
			for (NSString *refStudyUID in studyUIDSet)
			{
				//------------------currentStudyItem---------------------- >Include 'Hierarchical SOP Instance Reference Macro' Table C.17-3
				NSString *refStudyItem = [DICMC170602 setDICMItemForKey:refStudySQ index:studyItemCounter];
				[DICMC170602 setDICMString:refStudyUID forKey:[refStudyItem stringByAppendingPathComponent:@"0020000DUI"]];
				NSString *refSeriesSQ = [DICMC170602 setDICMSQForKey:[refStudyItem stringByAppendingPathComponent:@"00081115SQ"]];
				if (multiStudy) 
				{
					NSString *equalStudyItem = [DICMC170602 setDICMItemForKey:equalStudySQ index:studyItemCounter];
					[DICMC170602 setDICMString:refStudyUID forKey:[equalStudyItem stringByAppendingPathComponent:@"0020000DUI"]];
					NSString *equalSeriesSQ = [DICMC170602 setDICMSQForKey:[equalStudyItem stringByAppendingPathComponent:@"00081115SQ"]];
					NSString *equalSeriesItem = [DICMC170602 setDICMItemForKey:equalSeriesSQ index:1];
					
					
					//define equal series UID
					
					NSUInteger refStudyUIDLength = [refStudyUID length];
					NSString *refStudyUIDShortened;
					if (refStudyUIDLength < 44) refStudyUIDShortened = refStudyUID;
					else refStudyUIDShortened = [refStudyUID substringWithRange:NSMakeRange(refStudyUIDLength-44,43)];					
					[DICMC170602 setDICMString:[NSString stringWithFormat:@"1.3.6.1.4.1.23650.11.%@",refStudyUIDShortened] forKey:[equalSeriesItem stringByAppendingPathComponent:@"0020000EUI"]];					
					//other attributes level series
					//00080054.AE		3	RetrieveAETitle
					//0040E011.UI		3	RetrieveLocationUID
					//00880130.SH		3	Storage Media File-Set ID
					//00880140.UI		3	Storage Media File-Set UID
					//00081199.SQ		1	ReferencedSOPSequence
					//NSString *equalDocumentSQ   = [DICMC170602 setDICMSQForKey:[equalSeriesItem stringByAppendingPathComponent:@"00081199SQ"]];
					//NSString *equalDocumentItem = [DICMC170602 setDICMItemForKey:equalDocumentSQ index:1];
					//[DICMC170602 setDICMString:@"1.2.840.10008.5.1.4.1.1.88.59" forKey:[equalDocumentItem stringByAppendingPathComponent:@"00081150UI"]];
					//[DICMC170602 setDICMString:[[FoundationDICM sharedManager]newUID] forKey:[equalDocumentItem stringByAppendingPathComponent:@"00081155UI"]];

                     //>Include			'SOP Instance Reference Macro' Table 10-11
					 //>00081150		1	ReferencedSOPCLassUID
					 //0081155		1	Referenced SOPInstanceUID
					 //>0040A170	3	PurposeOfReferenceCodeSequence
					 //>>Include		'Code Sequence Macro' Table 8.8-1
					 //>04000402	3	Referenced Digial Signature Sequence
					 //>>04000100	1	Digital Signature UID
					 //>>04000120	1	Signature
					 //>04000403	3	Referenced SOP Instance MAC Sequence
					 //>>04000010	1	MAC Calculation Transfer Syntax UID
					 //>>04000015	1	Mac Algorithm
					 //>>04000020	1	Data Elements Signed
					 //>>04000404	1	MAC

            }

				//define ref series set for the current study
				NSMutableSet *seriesUIDSet = [NSMutableSet set];				
				NSInteger currentStudyIndex = [studyUIDs indexOfObject:refStudyUID];
				while (currentStudyIndex != NSNotFound)
				{
					[seriesUIDSet addObject:[seriesUIDs objectAtIndex:currentStudyIndex]];					
					[studyUIDs replaceObjectAtIndex:currentStudyIndex withObject:@""];
					currentStudyIndex = [studyUIDs indexOfObject:refStudyUID];
				}					 
				NSUInteger seriesItemCounter = 1;
				for (NSString *refSeriesUID in seriesUIDSet)	 
				{	 
					NSString *refSeriesItem = [DICMC170602 setDICMItemForKey:refSeriesSQ index:seriesItemCounter];
					[DICMC170602 setDICMString:refSeriesUID forKey:[refSeriesItem stringByAppendingPathComponent:@"0020000EUI"]];					
					 //>>Include 'Hierarchical Series Reference Macro Table C.17-3a
                    
					  //0020000E		1	SeriesInstanceUID
					  //00080054		3	RetrieveAETitle
					  //0040E011		3	RetrieveLocationUID
					  //00880130	3	Storage Media File-Set ID
					  //00880140	3	Storage Media File-Set UID
					  //00081199		1	ReferencedSOPSequence
 
					NSString *refObjectSQ   = [DICMC170602 setDICMSQForKey:[refSeriesItem stringByAppendingPathComponent:@"00081199SQ"]];

					//register corresponding documents
					NSUInteger objectItemCounter = 1;
					NSInteger currentSeriesIndex = [seriesUIDs indexOfObject:refSeriesUID];
					while (currentSeriesIndex != NSNotFound)
					{
						NSString *refObjectItem = [DICMC170602 setDICMItemForKey:refObjectSQ index:objectItemCounter];
						[DICMC170602 setDICMString:@"1.2.840.10008.5.1.4.1.1.7" forKey:[refObjectItem stringByAppendingPathComponent:@"00081150UI"]];
						[DICMC170602 setDICMString:[objectUIDs objectAtIndex:currentSeriesIndex] forKey:[refObjectItem stringByAppendingPathComponent:@"00081155UI"]];					
						
						 //>Include			'SOP Instance Reference Macro' Table 10-11
						 //>00081150		1	ReferencedSOPCLassUID
						 //>00081155		1	Referenced SOPInstanceUID
						 //>0040A170	3	PurposeOfReferenceCodeSequence
						 //>>Include		'Code Sequence Macro' Table 8.8-1
						 //>04000402	3	Referenced Digial Signature Sequence
						 //>>04000100	1	Digital Signature UID
						 //>>04000120	1	Signature
						 //>04000403	3	Referenced SOP Instance MAC Sequence
						 //>>04000010	1	MAC Calculation Transfer Syntax UID
						 //>>04000015	1	Mac Algorithm
						 //>>04000020	1	Data Elements Signed
						 //>>04000404	1	MAC
						 
						[seriesUIDs replaceObjectAtIndex:currentSeriesIndex withObject:@""];
						currentSeriesIndex = [seriesUIDs indexOfObject:refSeriesUID];
						objectItemCounter++;
					}
					seriesItemCounter++;
				}
				studyItemCounter++;
			}			
			return [NSDictionary dictionaryWithDictionary:DICMC170602];
		//}
		//return nil;
	}
	return nil;
}
*/

+(NSDictionary*)DICMC240200EncapsulatedCDAWithDA:(NSString*)DA
                                              TM:(NSString*)TM
                                           title:(NSString*)title
                                           HL7II:(NSString*)HL7II
                                            data:(NSData*)data
{
    NSMutableDictionary *DICMC240200 = [NSMutableDictionary dictionaryWithCapacity:11];
    
    [DICMC240200 setDICMString:@"1" forKey:@"00200013IS"];//InstanceNumber 1
    [DICMC240200 setDICMString:DA forKey:@"00080023DA"];//ContentDate 2
    [DICMC240200 setDICMString:TM forKey:@"00080033TM"];//ContentTime 2
    [DICMC240200 setDICMString:[DA stringByAppendingString:TM] forKey:@"0008002ADT"];//AcquisitionDateTime 2
    [DICMC240200 setDICMString:@"YES" forKey:@"00280301CS"];//BurnedInAnnotation 1
    [DICMC240200 setDICMString:DA forKey:@"00400244DA"];//PerformedProcedureStepStartDate
    [DICMC240200 setDICMString:TM forKey:@"00400245TM"];//PerformedProcedureStepStartTime
    [DICMC240200 setDICMString:HL7II forKey:@"0040E001ST"];//0040E001 HL7InstanceIdentifier
    [DICMC240200 setDICMString:title forKey:@"00420010ST"];//00420010 DocumentTitle 2
    [DICMC240200 setDICMData:data forKey:@"00420011OB"];//00420010 DocumentTitle 2
    [DICMC240200 setDICMString:@"text/xml" forKey:@"00420012ST"];//00420010 DocumentTitle 2

    return [NSDictionary dictionaryWithDictionary:DICMC240200];
}

//----------------------------------------------------------------------
#pragma mark -
#pragma mark DICM 3.3 Annex C modules COMMON


+(NSDictionary*)DICMC120100ForSOPClassUID1:(NSString*)SOPClassUID
                           SOPInstanceUID1:(NSString*)SOPInstanceUID
                                  charset1:(NSString*)charset
                                       DA1:(NSString*)DA
                                       TM1:(NSString*)TM
                                        TZ:(NSString*)TZ
{
	//==========
	//SOP Common
	//==========
		
	NSMutableDictionary *DICMC120100 = [NSMutableDictionary dictionaryWithCapacity:5];
	[DICMC120100 setDICMString:SOPClassUID	  forKey:@"00080016UI"];//SOPClassUID	1
	[DICMC120100 setDICMString:SOPInstanceUID forKey:@"00080018UI"];//SOPInstanceUID 1
	[DICMC120100 setDICMString:charset	      forKey:@"00080005CS"];//arbitrary UTF-8 @"ISO_IR 192" 1c
	[DICMC120100 setDICMString:DA	          forKey:@"00080012DA"];//InstanceCreationDate 3
	[DICMC120100 setDICMString:TM	          forKey:@"00080013TM"];//InstanceCreationTime 3
    [DICMC120100 setDICMString:TZ             forKey:@"00080201SH"];//Timezone Offset From UTC 3

	//3
	//[DICMC120100 setDICMString:@"1.2.840.10008.5.1.4.1.1.7"	forKey:@"00080014UI"];//InstanceCreatorUID
	
	//0008001A	3	RelatedGeneralSOPClassUID
	//0008001B	3	OriginalSpecializedSOPClassUID
	
	//00080110	3	CodingShemeIdentificationSequence
	//>00080102	1	CodingSchemeDesignator
	//>00080112	1c	Coding Scheme Registry
	//>0008010C	1c	Coding Scheme UID
	//>00080114	2c	CodingSchemeExternalID
	//>00080115	3	CodingSchemeName
	//>00080103	3	CodingSchemeVersion
	//>00080116	3	Coding Scheme Responsible Organization
	
	//0018A001	3	Contributing Equipment Sequence
	//>0040A170	1	Purpose of Reference Code Sequence
	//>>Include 'Code Sequence Macro' Table 8.8-1
	//>00080070	1	Manufacturer
	//>00080080	3	InstitutionName
	//>00080081	3	Institution Address
	//>00081010	3	Station Name
	//>00081040	3	Institutional Department name
	//>00081070	3	Operator's Name
	//>00081072	3	Operator Identification Sequence
	//>>Include 'Person Identification Macro' Table 10-1
	//>00081090	3	Manufacturer'sModelName
	//>00181000	3	Device Serial Number
	//>00181020	3	Software Versions
	//>00181050 3	Spatial Resolution
	//>00181200	3	Date of Last Calibration
	//>00181201	3	Time of Last Calibration
	//>0018A002	3	Contribution DateTime
	//>0018A003	3	Contribution Description
	//00200013	3	Instance Number
	
	//01000410	3	SOP Instance Status [NS|OR|AO|AC]
	//01000420	3	SOP Authorization DateTime
	//01000424	3	SOP AUthorization Comment
	//01000426	3	Authorization Equipment Certification Number
	//>Include 'Digital Signatures Macro' Table C.12-6
	
	//04000500	1C	Encrypted Attributes Sequence
	//>04000510	1	Encrypted Content Transfer Syntax UID
	//>04000520	1	Encrypted Content
	//04000561	3	Original Attributes Sequence
	//>04000564	2	Source of Previous Values
	//>04000562	1	Attribute Modification DateTime
	//>04000563	1	Modifying System
	//>04000565	1	Reason for the Attribute Modification [COERCE|CORRECT]
	//>04000550	1	Modified Attribute Sequence
	//>>Any Attribute from the main data set that was modified or removed; may include Sequence Attributes and their Items
	
	//0040A390	1c	HL7 Structured Documente Reference Sequence
	//>Include 'SOP Instance reference Macro' Table 10-11
	//>0040E001	1	HL7 Instance Identifier
	//>0040E010	3	Retrieve URI
	
	return [NSDictionary dictionaryWithDictionary:DICMC120100];
}
@end
