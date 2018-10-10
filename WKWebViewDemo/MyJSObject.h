//
//  MyJSObject.h
//  WKWebViewDemo
//
//  Created by wcx on 2018/10/10.
//  Copyright © 2018 wcx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PersonJSExport.h"
NS_ASSUME_NONNULL_BEGIN

@interface MyJSObject : NSObject<PersonJSExport>
- (void)nslog:(NSString *)str;
@end

NS_ASSUME_NONNULL_END
