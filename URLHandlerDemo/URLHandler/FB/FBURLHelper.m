//
//  FBURLHelper.m
//  FBAppContext
//
//  Created by zhangzy10 on 2020/7/24.
//  Copyright © 2020 Fenbi. All rights reserved.
//

#import "FBURLHelper.h"

@implementation FBURLHelper
+ (NSString *)urlDecode:(NSString*)url
{
    if (url) {
        CFStringRef decodedCFString = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (__bridge CFStringRef) url, CFSTR(""), kCFStringEncodingUTF8);

        // We need to replace "+" with " " because the CF method above doesn't do it
        NSString *decodedString = [[NSString alloc] initWithString:(__bridge_transfer NSString*) decodedCFString];
        return decodedString;
    }
    return nil;
}

+ (NSString *)urlEncode:(NSString*)url {
    if (url) {
        NSString *escapedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                    NULL,
                                                                                                    (__bridge CFStringRef) url,
                                                                                                    NULL,
                                                                                                    (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                    kCFStringEncodingUTF8));
        return escapedString;
    }
    return nil;
}
@end
