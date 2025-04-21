//
//  FBURLHelper.h
//  FBAppContext
//
//  Created by zhangzy10 on 2020/7/24.
//  Copyright © 2020 Fenbi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBURLHelper : NSObject
+ (NSString *)urlDecode:(NSString*)url;
+ (NSString *)urlEncode:(NSString*)url;
@end

NS_ASSUME_NONNULL_END
