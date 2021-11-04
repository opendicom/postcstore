#import <Foundation/Foundation.h>
#import "printfLog.h"

void printfLog(NSString *format, ...) {
    va_list argList;
    va_start (argList, format);

    NSString *string;
    string = [[NSString alloc] initWithFormat: format
                               arguments: argList];
    va_end (argList);
    printf ("%s\n", [string UTF8String]);
}
