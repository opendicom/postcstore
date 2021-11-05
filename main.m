#import <Foundation/Foundation.h>
#import "printfLog.h"

#import "NSURLComponents+PCS.h"

#import "RS.h"
#import "RSDataResponse.h"
#import "RSErrorResponse.h"
#import "RSFileResponse.h"
#import "RSStreamedResponse.h"


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
    [task waitUntilExit];
    return [task terminationStatus];
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
   
   NSString *contentType=[[[contentTypeBoundary[0]
    stringByReplacingOccurrencesOfString:@"\"" withString:@""]
    stringByReplacingOccurrencesOfString:@"'" withString:@""]
    stringByReplacingOccurrencesOfString:@" " withString:@""];
   printfLog(@"#%i  Content-Type: %@",request.socket, contentType);

   NSString *boundary=nil;
   NSData *boundaryData=nil;
   if (contentTypeBoundary.count ==2)
   {
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
      boundaryData=[[NSString stringWithFormat:@"\r\n--%@",boundary] dataUsingEncoding:NSISOLatin1StringEncoding];
   }
   
   
   
   
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
#pragma mark ·· application/dicom
         
         /*
          cada parte está delimitada por :
          - principio: preámbulo de 128 ceros y letras DICM
          - fin: boundary del item siguiente o último boundary
          */

         if (!boundaryData)
            return [RSErrorResponse responseWithClientError:404 message:@"Content-Type <pre>%@</pre> should contain one boundary=",request.contentType];

         //extract dicom from body
         unsigned long bodyLength=request.data.length;
         unsigned long bodyOffsetMax=bodyLength-1000;
         int counter=0;
         NSString *dirPath=[[args[2] stringByAppendingPathComponent:boundary] stringByAppendingPathComponent:[ISO8601 stringFromDate:[NSDate date]]];
         printfLog(@"#%i  dirPath:%@",request.socket, dirPath);
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
                bodyRange.location=bodyLength;
             }
             else
             {
               if (counter==0)
               {
                  [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
                  if (error) return [RSErrorResponse responseWithServerError:kRSHTTPStatusCode_InsufficientStorage message:@"intermediate storage not available"];
               }
               counter++;
 
                //new bodyRange
               bodyRange.location=DICMRange.location + DICMRange.length;
               bodyRange.length=bodyLength - bodyRange.location;
            
               //find next boundary
               boundaryRange=[request.data rangeOfData:boundaryData options:0 range:bodyRange];
               if (boundaryRange.location==NSNotFound)
                  return [RSResponse responseWithStatusCode:kRSHTTPStatusCode_BadRequest];
               
               //new bodyRange
               bodyRange.location=boundaryRange.location + boundaryRange.length;
               bodyRange.length=bodyLength - bodyRange.location;

               //save dicom file
               NSRange fileRange=NSMakeRange(DICMRange.location, boundaryRange.location - DICMRange.location);
               NSString *filePath=[dirPath stringByAppendingFormat:@"/%i.dcm",counter];
               [[request.data subdataWithRange:fileRange]writeToFile:filePath atomically:NO];
            }
         }
         //send contents of dirPath
         NSMutableData *readData=[NSMutableData data];
         /*
          /usr/local/bin/storescu +sd +sp *.dcm +rn -xv -aet STORESCU -aec DCM4CHEE localhost 11112 /Users/Shared/myboundary
          
          @"+sd",   //scan directory one level
          @"+sp",   //scan pattern
          @"*.dcm", //files ending with .dcm
          @"+rn",   //rename with .done or .bad (ignore these files on the next execution)
          @"-xv",   //prefer jpeg 2000
          @"-aet",  //local aet
          aet,      //=first segment of path
          @"-aec",  //aet of called pacs
          aec,      //=second segment of path
          args[3],  //=host of pacs
          args[4],  //=port of pacs
          dirPath   //directory to scan
          */
         
         int taskReturnInt=task(@"/usr/local/bin/storescu",
                                @[
                                   @"+sd",
                                   @"+sp",
                                   @"*.dcm",
                                   @"+rn",
                                   @"-xv",
                                   @"-aet",
                                   aet,
                                   @"-aec",
                                   aec,
                                   args[3],
                                   args[4],
                                   dirPath
                                ],
                                readData
                                );
         printfLog(@"#%i  task taskReturnInt: %i",request.socket, taskReturnInt);
         
         return [RSDataResponse responseWithData:readData contentType:@"text/plain"];
      }
         break;

      case 1:
      {
#pragma mark ·· application/dicom+xml

         if (!boundaryData)
            return [RSErrorResponse responseWithClientError:404 message:@"Content-Type <pre>%@</pre> should contain one boundary=",request.contentType];

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
