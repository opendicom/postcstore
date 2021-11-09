#import <Foundation/Foundation.h>
#import "printfLog.h"

#import "RS.h"
#import "RSDataResponse.h"
#import "RSErrorResponse.h"
//#import "RSFileResponse.h"
//#import "RSStreamedResponse.h"


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

#pragma mark static data
   
   //static dicom file start data
   uint32 DICM=0x4D434944;
   uint32 group2size=0x02;
   uint16 group2sizeVr=0x4C55;
   NSMutableData *DICMPrefix=[NSMutableData dataWithLength:128];
   [DICMPrefix appendBytes:&DICM length:4];
   [DICMPrefix appendBytes:&group2size length:4];
   [DICMPrefix appendBytes:&group2sizeVr length:2];

   NSString *XMLPrefix=@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>";

   NSData *rnrn=[@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding];
   uint8 space=' ';
   //fileManager
   NSFileManager *fileManager=[NSFileManager defaultManager];
   
   //timestamp
   NSISO8601DateFormatter *ISO8601;
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

   
#pragma mark · generic parsing variables
   
   if (!boundaryData)
      return [RSErrorResponse responseWithClientError:404 message:@"Content-Type <pre>%@</pre> should contain one boundary=",request.contentType];

   //extract dicom from body
   unsigned long bodyLength=request.data.length;
   unsigned long bodyOffsetMax=bodyLength-37;//arbitrarily size of xml prefix (that is .... if there is no space not even for an xml prefix... no reason to parse more data)
   int counter=0;
   NSArray *ISO8601datetime=[[ISO8601 stringFromDate:[NSDate date]]componentsSeparatedByString:@" "];
   NSString *ISO8601timestamp=[ISO8601datetime componentsJoinedByString:@"T"];
   
   NSString *dirPath=[[args[2] stringByAppendingPathComponent:boundary] stringByAppendingPathComponent:ISO8601timestamp];
   printfLog(@"#%i  dirPath:%@",request.socket, dirPath);
   NSError *error;
   NSRange bodyRange=NSMakeRange(0,bodyLength);
   NSRange boundaryRange=[request.data rangeOfData:boundaryData options:0 range:bodyRange];
   //skip first boundary
   bodyRange.location=boundaryRange.location + boundaryRange.length + 2; // --\r\n
   bodyRange.length=bodyRange.length - bodyRange.location;
   
#pragma mark · cases implemented
   
   switch ([
            @[
               @"multipart/related;type=application/dicom;",
               @"multipart/related;type=application/dicom+xml;"
            ]
            indexOfObject:contentType
            ]) {
      case NSNotFound:
         return [RSErrorResponse responseWithClientError:404 message:@"content-type: %@ not accepted",contentType];

         
      case 0:
      {
#pragma mark ·· application/dicom
         
         /*
          each part is supposed to be a complete dicom file.
          we do not check the header of each part.
          
          - parte start: 128 zeros + DICM
          - parte end: boundary
          */
         NSRange DICMRange=NSMakeRange(0,0);

         while (bodyRange.location < bodyOffsetMax)
         {
            //find next DICM
             DICMRange=[request.data rangeOfData:DICMPrefix options:0 range:bodyRange];
            
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
      }
         break;

      case 1:
      {
#pragma mark ·· application/dicom+xml

         /*
          the enclosed part is also an xml
          
          But we want to check that and check also which part is related to which base part.
          This is the generic case, which requires we know the part type and part uri when there is one
          
          - content start: after \r\n\r\n
          - content end: boundary
          - header is in plain text
          */
         NSRange headRange=NSMakeRange(0,0);
         NSRange rnrnRange=NSMakeRange(0,0);
         NSRange contentRange=NSMakeRange(0,0);
         NSMutableArray *partsType=[NSMutableArray array];
         NSMutableArray *partsContent=[NSMutableArray array];
         NSMutableArray *partsUri=[NSMutableArray array];

         while (bodyRange.location < bodyOffsetMax)
         {
            //find next xml
             rnrnRange=[request.data rangeOfData:rnrn options:0 range:bodyRange];
            
             if (rnrnRange.location==NSNotFound)
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
                
               //parse headRange
               NSString *ct=nil;
               NSString *cl=nil;
               headRange.location=bodyRange.location;
               headRange.length=rnrnRange.location - headRange.location;
               NSString *headString=[[NSString alloc]initWithData: [request.data subdataWithRange:headRange] encoding:NSASCIIStringEncoding];
               NSArray *headStrings=[headString componentsSeparatedByString:@"\r\n"];
               for (NSString *headKeyValueString in headStrings)
               {
                  if (headKeyValueString.length)
                  {
                     NSString *spaceTrimmed=[headKeyValueString stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
                     NSArray *headKeyValueArray=[spaceTrimmed componentsSeparatedByString:@":"];
                     if (headKeyValueArray.count != 2)
                        return [RSErrorResponse responseWithClientError:404 message:@"bad part head <pre>%@</pre>",headString];
                     NSString *key=[headKeyValueArray[0] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
                     NSString *value=[headKeyValueArray[1] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
                     if ([key isEqualToString:@"Content-Type"])     ct=value;
                     if ([key isEqualToString:@"Content-Location"]) cl=value;
                  }
               }

               //new bodyRange
               bodyRange.location=rnrnRange.location + rnrnRange.length;
               bodyRange.length=bodyLength - bodyRange.location;
            
               //find content delimited by next boundary
               boundaryRange=[request.data rangeOfData:boundaryData options:0 range:bodyRange];
               if (boundaryRange.location==NSNotFound)
                  return [RSResponse responseWithStatusCode:kRSHTTPStatusCode_BadRequest];
                
               contentRange.location=bodyRange.location;
                contentRange.length=boundaryRange.location - contentRange.location;
                
               if (ct)
               {
                  [partsType addObject:ct];
                  [partsContent addObject:[request.data subdataWithRange:contentRange]];
                  if (cl) [partsUri addObject:cl];
                  else [partsUri addObject:@""];
               }
                
               //new bodyRange
               bodyRange.location=boundaryRange.location + boundaryRange.length;
               bodyRange.length=bodyLength - bodyRange.location;
            }
         }
         
         for (int index = 0; index < counter; index++)
         {
            if ([partsType[index] hasPrefix:@"application/dicom+xml"])
            {
               //specialization with dicom+xml, might be generalized
               NSMutableString *XMLString=[[NSMutableString alloc] initWithData:partsContent[index] encoding:NSUTF8StringEncoding];
               if (!XMLString) return [RSErrorResponse responseWithClientError:404 message:@"bad XML encoding"];
               if (![XMLString hasPrefix:XMLPrefix]) return [RSErrorResponse responseWithClientError:404 message:@"XML with no prefix"];
               
               //find bulkdata reference(s)
               NSRange XMLStringRange=NSMakeRange(0, XMLString.length);
               while (1)
               {
                  NSRange bulkRange=[XMLString rangeOfString:@"<BulkData uri=\"" options:0 range:XMLStringRange];
                  if (bulkRange.location==NSNotFound) break;
                  
                  NSRange uriRange=NSMakeRange(bulkRange.location + bulkRange.length,0);
                  NSRange nextDoubleQuote=[XMLString rangeOfString:@"\"" options:0 range:NSMakeRange(uriRange.location, XMLString.length - uriRange.location)];
                  uriRange.length=nextDoubleQuote.location - uriRange.location;
                  NSString *uri=[XMLString substringWithRange:uriRange];
                  
                  NSUInteger bulkdataIndex=[partsUri indexOfObject:uri];
                  if (bulkdataIndex==NSNotFound)
                     [RSErrorResponse responseWithClientError:404 message:@"XML bulkdata %@ not found",uri];
                  
                  NSRange nextLesser=[XMLString rangeOfString:@"<" options:0 range:NSMakeRange(uriRange.location, XMLString.length - uriRange.location)];
                  bulkRange.length=nextLesser.location - bulkRange.location;
                  [XMLString deleteCharactersInRange:bulkRange];
                  //insert base64 representation of XMLData[1] into XMLData[0]
                  NSString *base64enclosure=nil;
                  if ([partsContent[index] length] % 2)
                  {
                     NSMutableData *spacepadded=[NSMutableData dataWithData:partsContent[index]];
                     [spacepadded appendBytes:&space length:1];
                     base64enclosure=[NSString stringWithFormat:@"<InlineBinary>%@</InlineBinary>", [spacepadded base64EncodedStringWithOptions:0]];
                  }
                  else base64enclosure=[NSString stringWithFormat:@"<InlineBinary>%@</InlineBinary>", [partsContent[index] base64EncodedStringWithOptions:0]];
                  [XMLString insertString:base64enclosure atIndex:bulkRange.location];
                  XMLStringRange.location=bulkRange.location + base64enclosure.length;
                  XMLStringRange.length=XMLString.length - XMLStringRange.location;
               }
               NSString *filePath=[dirPath stringByAppendingFormat:@"/%i.dcm",index];
               NSMutableData *logData=[NSMutableData data];
               
               //convert XMLString to DICMData
               NSTask *XMLDCMtask=[[NSTask alloc]init];
               [XMLDCMtask setLaunchPath:@"/Applications/dcm4che-5.23.2/bin/xml2dcm"];
               [XMLDCMtask setArguments:
                @[
                   @"-x",
                   @"-",
                   @"-o",
                   filePath
                ]
                ];
               //LOG_INFO(@"%@",[task arguments]);
               NSPipe *writePipe = [NSPipe pipe];
               NSFileHandle *writeHandle = [writePipe fileHandleForWriting];
               [XMLDCMtask setStandardInput:writePipe];
               
               NSPipe* readPipe = [NSPipe pipe];
               NSFileHandle *readingFileHandle=[readPipe fileHandleForReading];
               [XMLDCMtask setStandardOutput:readPipe];
               [XMLDCMtask setStandardError:readPipe];
               
               [XMLDCMtask launch];
               [writeHandle writeData:[XMLString dataUsingEncoding:NSUTF8StringEncoding]];
               [writeHandle closeFile];
               
               NSData *dataPiped = nil;
               while((dataPiped = [readingFileHandle availableData]) && [dataPiped length])
               {
                   [logData appendData:dataPiped];
               }
               //while( [task isRunning]) [NSThread sleepForTimeInterval: 0.1];
               //[task waitUntilExit];      // <- This is VERY DANGEROUS : the main runloop is continuing...
               //[aTask interrupt];
               
               [XMLDCMtask waitUntilExit];
               if ([XMLDCMtask terminationStatus]!=0)
                  NSLog(@"%@",[[NSString alloc] initWithData:logData encoding:NSUTF8StringEncoding]);
            }
         }
         
         

      }
         break;
         
      default:
         return [RSErrorResponse responseWithServerError:404 message:@"multiple application/dicom or single application/dicom+xml with encapsulated cda are the only cases accepted yet"];

   }

#pragma mark · send dirPath's contents
   
   //https://support.dcmtk.org/docs/storescu.html
   /*
    /usr/local/bin/storescu +sd +sp *.dcm +rn -xv -aet STORESCU -aec DCM4CHEE localhost 11112 /Users/Shared/myboundary
    
    @"+sd",   //scan directory one level
    @"+r",    //recurse
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
   
   NSTask *task=[[NSTask alloc]init];
   [task setLaunchPath:@"/usr/local/bin/storescu"];
   [task setArguments:
    @[
       @"+sd",
       @"+r",
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
    ]
    ];
   //LOG_INFO(@"%@",[task arguments]);
   
   NSPipe* readPipe = [NSPipe pipe];
   NSFileHandle *readingFileHandle=[readPipe fileHandleForReading];
   [task setStandardOutput:readPipe];
   [task setStandardError:readPipe];
   NSData *dataPiped = nil;
   [task launch];
   NSMutableData *readData=[NSMutableData data];
   while((dataPiped = [readingFileHandle availableData]) && [dataPiped length])
   {
       [readData appendData:dataPiped];
   }
   [task waitUntilExit];
   printfLog(@"#%i  task taskReturnInt: %i",request.socket, [task terminationStatus]);

#pragma mark TODO correct status
   return [RSDataResponse responseWithData:readData contentType:@"text/plain"];


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
