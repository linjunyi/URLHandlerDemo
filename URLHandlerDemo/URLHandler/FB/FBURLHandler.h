//
//  FBURLHandler.h
//  FBAppContext
//
//  Created by koujun on 2022/8/31.
//  Copyright © 2022 Fenbi. All rights reserved.
//

#import "FBURLRouter.h"

NS_ASSUME_NONNULL_BEGIN

@interface FBURLHandler : NSObject
@property (nonatomic, readonly) NSUInteger matchedPatternIndex;
+(NSArray<NSString*>*)patterns;
+(FBURLHandlerType)type;//default is native
+(NSString*)usage;
+(nullable NSArray<NSString*>*)requiredKeys;

+ (NSString*)urlWithParameters:(NSDictionary*_Nullable)parameters;
+ (NSString*)url:(NSString *)url withParameters:(NSDictionary*_Nullable)parameters;

//subclass override
- (void)handleUrl:(NSURL*)url navi:(UINavigationController*)navi parameters:(NSDictionary<NSString*,NSString*>*_Nullable)parameters;
+(nullable NSArray<NSString*>*)additionalRequiredKeys;
+(nullable NSArray<NSString*>*)optionalKeys;

+ (BOOL)shouldCreateNavigationControllerWhenHandlePush:(NSString*)route patternIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
