#import <sys/stat.h>
#import "RSFileResponse.h"
#import "printfLog.h"

#define kFileReadBufferSize (32 * 1024)

@interface RSFileResponse () {
@private
  NSString* _path;
  NSUInteger _offset;
  NSUInteger _size;
  int _file;
}
@end

@implementation RSFileResponse

+ (instancetype)responseWithFile:(NSString*)path {
  return [[[self class] alloc] initWithFile:path];
}

+ (instancetype)responseWithFile:(NSString*)path isAttachment:(BOOL)attachment {
  return [[[self class] alloc] initWithFile:path isAttachment:attachment];
}

+ (instancetype)responseWithFile:(NSString*)path byteRange:(NSRange)range {
  return [[[self class] alloc] initWithFile:path byteRange:range];
}

+ (instancetype)responseWithFile:(NSString*)path byteRange:(NSRange)range isAttachment:(BOOL)attachment {
  return [[[self class] alloc] initWithFile:path byteRange:range isAttachment:attachment];
}

- (instancetype)initWithFile:(NSString*)path {
  return [self initWithFile:path byteRange:NSMakeRange(NSUIntegerMax, 0) isAttachment:NO];
}

- (instancetype)initWithFile:(NSString*)path isAttachment:(BOOL)attachment {
  return [self initWithFile:path byteRange:NSMakeRange(NSUIntegerMax, 0) isAttachment:attachment];
}

- (instancetype)initWithFile:(NSString*)path byteRange:(NSRange)range {
  return [self initWithFile:path byteRange:range isAttachment:NO];
}

static inline NSDate* _NSDateFromTimeSpec(const struct timespec* t) {
  return [NSDate dateWithTimeIntervalSince1970:((NSTimeInterval)t->tv_sec + (NSTimeInterval)t->tv_nsec / 1000000000.0)];
}

- (instancetype)initWithFile:(NSString*)path byteRange:(NSRange)range isAttachment:(BOOL)attachment {
  struct stat info;
  if (lstat([path fileSystemRepresentation], &info) || !(info.st_mode & S_IFREG)) {
    return nil;
  }
#ifndef __LP64__
  if (info.st_size >= (off_t)4294967295) {  // In 32 bit mode, we can't handle files greater than 4 GiBs (don't use "NSUIntegerMax" here to avoid potential unsigned to signed conversion issues)
    return nil;
  }
#endif
  NSUInteger fileSize = (NSUInteger)info.st_size;
  
  BOOL hasByteRange = ((range.location != NSUIntegerMax) || (range.length > 0));
  if (hasByteRange) {
    if (range.location != NSUIntegerMax) {
      range.location = MIN(range.location, fileSize);
      range.length = MIN(range.length, fileSize - range.location);
    } else {
      range.length = MIN(range.length, fileSize);
      range.location = fileSize - range.length;
    }
    if (range.length == 0) {
      return nil;  // TODO: Return 416 status code and "Content-Range: bytes */{file length}" header
    }
  } else {
    range.location = 0;
    range.length = fileSize;
  }
  
  if ((self = [super init])) {
    _path = [path copy];
    _offset = range.location;
    _size = range.length;
    if (hasByteRange) {
      [self setStatusCode:206];//PartialContent];
      [self setValue:[NSString stringWithFormat:@"bytes %lu-%lu/%lu", (unsigned long)_offset, (unsigned long)(_offset + _size - 1), (unsigned long)fileSize] forAdditionalHeader:@"Content-Range"];
      printfLog(@"Using content bytes range [%lu-%lu] for file \"%@\"", (unsigned long)_offset, (unsigned long)(_offset + _size - 1), path);
    }
    
    if (attachment) {
      NSString* fileName = [path lastPathComponent];
      NSData* data = [[fileName stringByReplacingOccurrencesOfString:@"\"" withString:@""] dataUsingEncoding:NSISOLatin1StringEncoding allowLossyConversion:YES];
      NSString* lossyFileName = data ? [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding] : nil;
      if (lossyFileName) {
          
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSString* value = [NSString stringWithFormat:@"attachment; filename=\"%@\"; filename*=UTF-8''%@", lossyFileName, CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)fileName, NULL, CFSTR(":@/?&=+"), kCFStringEncodingUTF8))];
#pragma clang diagnostic pop
        [self setValue:value forAdditionalHeader:@"Content-Disposition"];
      }
    }
    
    static NSDictionary* _overrides = nil;
    if (_overrides == nil) {
        _overrides = [[NSDictionary alloc] initWithObjectsAndKeys:
                        @"text/css", @"css",
                        nil];
    }
    NSString* mimeType = nil;
    NSString *extension = [[_path pathExtension] lowercaseString];
    if (extension.length) {
          mimeType = [_overrides objectForKey:extension];
          if (mimeType == nil) {
              CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
              if (uti) {
                  mimeType = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType));
                  CFRelease(uti);
              }
          }
      }
      if (mimeType == nil) mimeType=@"application/octet-stream";
    self.contentLength = _size;
    self.lastModifiedDate = _NSDateFromTimeSpec(&info.st_mtimespec);
    self.eTag = [NSString stringWithFormat:@"%llu/%li/%li", info.st_ino, info.st_mtimespec.tv_sec, info.st_mtimespec.tv_nsec];
  }
  return self;
}

- (BOOL)open:(NSError**)error {
  _file = open([_path fileSystemRepresentation], O_NOFOLLOW | O_RDONLY);
  if (_file <= 0) {
    if (error) {
      *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithUTF8String:strerror(errno)]}];
    }
    return NO;
  }
  if (lseek(_file, _offset, SEEK_SET) != (off_t)_offset) {
    if (error) {
      *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithUTF8String:strerror(errno)]}];
    }
    close(_file);
    return NO;
  }
  return YES;
}

- (NSData*)readData:(NSError**)error {
  size_t length = MIN((NSUInteger)kFileReadBufferSize, _size);
  NSMutableData* data = [[NSMutableData alloc] initWithLength:length];
  ssize_t result = read(_file, data.mutableBytes, length);
  if (result < 0) {
    if (error) {
      *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithUTF8String:strerror(errno)]}];
    }
    return nil;
  }
  if (result > 0) {
    [data setLength:result];
    _size -= result;
  }
  return data;
}

- (void)close {
  close(_file);
}

- (NSString*)description {
  NSMutableString* description = [NSMutableString stringWithString:[super description]];
  [description appendFormat:@"\n\n{%@}", _path];
  return description;
}

@end
