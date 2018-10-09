//
//  NSString+urlEncode.m
//  WKWebViewDemo
//
//  Created by wcx on 2018/10/8.
//  Copyright © 2018 wcx. All rights reserved.
//

#import "NSString+urlEncode.h"

@implementation NSString (urlEncode)
- (NSURL *)encodeUrl{
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    return [NSURL URLWithString:(NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]", NULL,kCFStringEncodingUTF8))];
#pragma clang diagnostic pop
}
@end
