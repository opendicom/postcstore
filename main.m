#import <Foundation/Foundation.h>
#import "printfLog.h"

#import "NSURLComponents+PCS.h"

#import "RS.h"
#import "RSDataResponse.h"
#import "RSErrorResponse.h"
#import "RSFileResponse.h"
#import "RSStreamedResponse.h"
#import "DICMTypes.h"
#import "NSString+PCS.h"
#import "NSData+PCS.h"
#import "NSURLSessionDataTask+PCS.h"
#import "NSMutableURLRequest+PCS.h"
#import "NSMutableString+DSCD.h"
#import "NSUUID+DICM.h"


static NSRegularExpression *UIRegex=nil;
static NSRegularExpression *SHRegex=nil;
static NSRegularExpression *DARegex=nil;
static NSRegularExpression *CSRegex=nil;
static NSArray *qidoLastPathComponent=nil;
static NSData *pdfContentType;

//static immutable find within NSData
static NSData *rn;
static NSData *rnrn;
static NSData *rnhh;
static NSData *contentType;
static NSData *CDAOpeningTag;
static NSData *CDAClosingTag;
static NSData *ctad;
static NSData *emptyJsonArray;



int task(NSString *launchPath, NSArray *launchArgs, NSMutableData *readData)
{
    NSTask *task=[[NSTask alloc]init];
    [task setLaunchPath:launchPath];
    [task setArguments:launchArgs];
    //LOG_INFO(@"%@",[task arguments]);
    
    NSPipe* readPipe = [NSPipe pipe];
    NSFileHandle *readingFileHandle=[readPipe fileHandleForReading];
    [task setStandardOutput:readPipe];
    [task setStandardError:readPipe];
    
    NSData *dataPiped = nil;
    [task launch];
    while((dataPiped = [readingFileHandle availableData]) && [dataPiped length])
    {
        [readData appendData:dataPiped];
    }
    //while( [task isRunning]) [NSThread sleepForTimeInterval: 0.1];
    //[task waitUntilExit];		// <- This is VERY DANGEROUS : the main runloop is continuing...
    //[aTask interrupt];
    [task waitUntilExit];
    int terminationStatus = [task terminationStatus];
    if (terminationStatus!=0) printfLog(@"ERROR task terminationStatus: %d",terminationStatus);
    return terminationStatus;
}



int main(int argc, const char* argv[]) {
@autoreleasepool {
  /*
   syntax:
   [0] postcstore
   [1] httpPort
   [2] dirPath
   [3] destAET@host:port
   [4]... local aets autorizados
   */
  NSArray *args=[[NSProcessInfo processInfo] arguments];
  if (args.count < 4) return 1;
                        
  //[0] cmd
  //NSString *commandName=args[0];
  //[1] httpPort
  long long httpPort=[args[1]longLongValue];
  if (httpPort < 1 || httpPort > 65535) return 1;
  //[2] dest

   //static dicom file start data
   uint32 DICM=0x4D434944;
   uint32 group2size=0x02;
   uint16 group2sizeVr=0x4C55;
   NSMutableData *DICMdata=[NSMutableData dataWithLength:128];
   [DICMdata appendBytes:&DICM length:4];
   [DICMdata appendBytes:&group2size length:4];
   [DICMdata appendBytes:&group2sizeVr length:2];

   NSFileManager *fileManager=[NSFileManager defaultManager];
   static NSISO8601DateFormatter *ISO8601;
   ISO8601=[[NSISO8601DateFormatter alloc]init];
   ISO8601.formatOptions=NSISO8601DateFormatWithFractionalSeconds;

#pragma mark -
  RS* postcstoreServer = [[RS alloc] init];

  
//-----------------------------------------------

#pragma mark GET info
  [postcstoreServer addHandler:@"GET" regex:[NSRegularExpression regularExpressionWithPattern:@".*" options:0 error:NULL]
     processBlock:^(RSRequest* request, RSCompletionBlock completionBlock)
   {completionBlock(^RSResponse* (RSRequest* request){
      return [RSDataResponse responseWithText:@"POSTCSTORE acepta POST application/dicom y application/dicom+xml exclusivamente, ambos con ruta host/{aet}/studies"];
  }(request));}];

   
#pragma mark POST

[postcstoreServer addHandler:@"POST" regex:[NSRegularExpression regularExpressionWithPattern:@"^/\\S{1,16}/\\S{1,16}/studies$" options:0 error:NULL]
   processBlock:^(RSRequest* request,RSCompletionBlock completionBlock)
   {completionBlock(^RSResponse* (RSRequest* request)
{
   
#pragma mark · body size
   if (request.data.length < 1000)
      return [RSErrorResponse responseWithClientError:404 message:@"body size: %lu bytes",request.data.length];

#pragma mark · aets in path
   NSURLComponents *urlComponents=[NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:NO];
    //scheme, user, password, host, port, path, query, fragment

   NSString *aet=[urlComponents.path componentsSeparatedByString:@"/"][1];
   NSUInteger aetIndex=[args indexOfObject:aet];
   if (aetIndex==NSNotFound)
      return [RSErrorResponse responseWithClientError:404 message:@"the path <pre>%@</pre> should contain authorized aets",urlComponents.path];

   NSString *aec=[urlComponents.path componentsSeparatedByString:@"/"][2];
   NSUInteger aecIndex=[args indexOfObject:aec];
   if (aecIndex==NSNotFound)
      return [RSErrorResponse responseWithClientError:404 message:@"the path <pre>%@</pre> should contain authorized aets",urlComponents.path];

#pragma mark · contentType
   NSArray *contentTypeBoundary=[request.contentType componentsSeparatedByString:@"boundary="];
   if (contentTypeBoundary.count !=2)
      return [RSErrorResponse responseWithClientError:404 message:@"Content-Type <pre>%@</pre> should contain one boundary=",request.contentType];

   
   NSString *boundary=nil;
   NSArray *simpleQuoteAroundBoundary=[contentTypeBoundary[1] componentsSeparatedByString:@"'"];
   switch (simpleQuoteAroundBoundary.count) {
      case 3:
         boundary=simpleQuoteAroundBoundary[1];
         break;
      case 1: //no simpleQuote
         break;

      default: //not authorized
         return [RSErrorResponse responseWithClientError:404 message:@"bad Content-Type boundary <pre>%@</pre>",request.contentType];
   }
   NSArray *doubleQuoteAroundBoundary=[contentTypeBoundary[1] componentsSeparatedByString:@"\""];
   switch (doubleQuoteAroundBoundary.count) {
      case 3:
         boundary=doubleQuoteAroundBoundary[1];
         break;
      case 1: //no doubleQuote
         break;

      default: //not authorized
         return [RSErrorResponse responseWithClientError:404 message:@"bad Content-Type boundary <pre>%@</pre>",request.contentType];
   }
   if (!boundary)
   {
      boundary=[contentTypeBoundary[1] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
      if ([[boundary componentsSeparatedByString:@" "]count]>1)
         return [RSErrorResponse responseWithClientError:404 message:@"bad Content-Type boundary <pre>%@</pre>",request.contentType];
   }
   NSData *boundaryData=[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSISOLatin1StringEncoding];
   NSString *boundaryString=[[NSString alloc]initWithData:boundaryData encoding:NSISOLatin1StringEncoding];
   
   
   
   NSString *contentType=[contentTypeBoundary[0] stringByReplacingOccurrencesOfString:@" " withString:@""];
   NSUInteger contentTypeIndex = [
                                  @[
                                     @"multipart/related;type=application/dicom;",
                                     @"multipart/related;type=application/dicom+xml;"
                                  ]
                                  indexOfObject:contentType
                                  ];
   
   
   switch (contentTypeIndex) {
      case NSNotFound:
         return [RSErrorResponse responseWithClientError:404 message:@"content-type: %@ not accepted",contentType];

      case 0:
      {
#pragma mark - application/dicom
         
         /*
          cada parte está delimitada por :
          - principio: preámbulo de 128 ceros y letras DICM
          - fin: boundary del item siguiente o último boundary
          */
         
         //extract dicom from body
         unsigned long bodyLength=request.data.length;
         unsigned long bodyOffsetMax=bodyLength-1000;
         printfLog(@"body size: %lu",request.data.length);
         int counter=0;
         NSString *dirPath=[[args[2] stringByAppendingPathComponent:boundaryString] stringByAppendingPathComponent:[ISO8601 stringFromDate:[NSDate date]]];
         NSError *error;
         NSRange DICMRange=NSMakeRange(0,0);
         NSRange boundaryRange=NSMakeRange(0,0);

         NSRange bodyRange=NSMakeRange(0,bodyLength);
         while (bodyRange.location < bodyOffsetMax)
         {
            //find next DICM
            DICMRange=[request.data rangeOfData:DICMdata options:0 range:bodyRange];
            if (DICMRange.location==NSNotFound)
            {
               if (counter==0) return [RSResponse responseWithStatusCode:kRSHTTPStatusCode_NoContent];
               counter++;
               [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
               if (error) return [RSErrorResponse responseWithServerError:kRSHTTPStatusCode_InsufficientStorage message:@"intermediate storage not available"];

               bodyRange.location=bodyLength;
            }
            else
            {
               //new bodyRange
               bodyRange.location=DICMRange.location + DICMRange.location;
               bodyRange.length=bodyLength - DICMRange.location - DICMRange.location;
            
               //find next boundary
               boundaryRange=[request.data rangeOfData:boundaryData options:0 range:bodyRange];
               if (boundaryRange.location==NSNotFound)
                  return [RSResponse responseWithStatusCode:kRSHTTPStatusCode_BadRequest];
               
               //new bodyRange
               bodyRange.location=boundaryRange.location + boundaryRange.location;
               bodyRange.length=bodyLength - boundaryRange.location - boundaryRange.location;

               //save dicom file
               NSRange fileRange=NSMakeRange(DICMRange.location,boundaryRange.location - DICMRange.location);
               NSString *filePath=[dirPath stringByAppendingFormat:@"/%i.dcm",counter];
               [[request.data subdataWithRange:fileRange]writeToFile:filePath atomically:NO];
            }
         }
         //send contents of dirPath
         NSMutableData *readData=[NSMutableData data];
         int taskReturnInt=task(@"/usr/local/bin/storescu",
                                @[
                                   @"+sd",
                                   @"aet",
                                   aet,
                                   @"aec",
                                   aec,
                                   @"-xv",
                                   args[4],
                                   args[5],
                                   dirPath
                                ],
                                readData
                                );
         
         return [RSDataResponse responseWithData:readData contentType:@"text/plain"];
      }
         break;

      case 1:
      {
#pragma mark - application/dicom+xml
      }
         break;

   }
   return [RSErrorResponse responseWithServerError:404 message:@"should contain return before in the method"];

}(request));}];




  


  
//-----------------------------------------------

#pragma mark -
#pragma mark run
  NSError *error=nil;
  
  [postcstoreServer startWithPort:httpPort maxPendingConnections:16 error:&error];
  while (true) {
      CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0, true);
  }
}//end autorelease pool
}
