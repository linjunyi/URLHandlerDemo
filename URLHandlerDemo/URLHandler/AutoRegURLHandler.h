//
//  AutoRegURLHandler.h
//  URLHandlerDemo
//
//  Created by 林君毅 on 2025/4/21.
//

#import "FBURLHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface AutoRegURLHandler : FBURLHandler

/*
 校验是否存在重复路由，建议只在debug环境下使用此方法
 */
+ (BOOL)checkValid:(NSString **)errorString;

@end

NS_ASSUME_NONNULL_END
