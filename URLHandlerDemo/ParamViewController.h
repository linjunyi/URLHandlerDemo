//
//  ParamViewController.h
//  URLHandlerDemo
//
//  Created by 林君毅 on 2025/4/21.
//

#import <UIKit/UIKit.h>
#import "ParamURLHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface ParamViewController : UIViewController

- (id)initWithCourseId:(NSString *)courseId param1:(NSString *)param1 param2:(NSString *)param2;

@end

NS_ASSUME_NONNULL_END
