//
//  PersonJSExport.h
//  WKWebViewDemo
//
//  Created by wcx on 2018/10/10.
//  Copyright © 2018 wcx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
NS_ASSUME_NONNULL_BEGIN

@protocol PersonJSExport <JSExport>
- (void)nslog:(NSString *)str; //协议里面要声明调用的方法
@end

NS_ASSUME_NONNULL_END
