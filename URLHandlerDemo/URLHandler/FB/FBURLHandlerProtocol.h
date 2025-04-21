//
//  Header.h
//  FBAppContext
//
//  Created by koujun on 2022/8/31.
//  Copyright © 2022 Fenbi. All rights reserved.
//

#ifndef FBURLHandlerProtocol_Header_h
#define FBURLHandlerProtocol_Header_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FBURLHandlerProtocol <NSObject>

+ (BOOL)canHandleUrl:(NSString*)urlString type:(FBURLHandlerType)type parameters:(NSDictionary**)parameters toURL:(NSURL *__autoreleasing *)URL matchedIndex:(NSUInteger*)matchedIndex;
+ (NSString*)urlWithParameters:(NSDictionary*)parameters;

- (void)handleUrl:(NSURL*)url navi:(UINavigationController*)navi parameters:(NSDictionary<NSString*,NSString*>*_Nullable)parameters;

- (NSUInteger)matchedPatternIndex;
- (void)setMatchedPatternIndex:(NSUInteger)matchedPatternIndex;

@optional

+ (BOOL)shouldCreateNavigationControllerWhenHandlePush:(NSString*)route patternIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
#endif /* FBURLHandlerProtocol_Header_h */
