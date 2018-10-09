//
//  NSString+urlEncode.h
//  WKWebViewDemo
//
//  Created by wcx on 2018/10/8.
//  Copyright © 2018 wcx. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (urlEncode)

/**
 处理中文url编码的问题
 有时候我们加载的URL中可能会出现中文，需要我们手动进行转码，但是同时又要保证URL中的特殊字符保持不变，那么我们就可以使用下面的方法

 @return nsurl
 */
- (NSURL *)encodeUrl;
@end

NS_ASSUME_NONNULL_END
