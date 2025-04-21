//
//  FBURLRouter.h
//  FBAppContext
//
//  Created by KouJun on 2019/1/9.
//  Copyright © 2019 Fenbi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_OPTIONS(NSUInteger,FBURLHandlerType) {
    FBURLHandlerTypeNative = 0x1,
    FBURLHandlerTypeWeb = 0x1 << 1,
    FBURLHandlerTypeAll = FBURLHandlerTypeNative | FBURLHandlerTypeWeb,
};

typedef BOOL (^FBURLHandlerProcessorWithResult)(NSURL*url,FBURLHandlerType type,UINavigationController*_Nullable navi, NSDictionary *_Nullable extra, BOOL checkCanHandle);

@interface FBURLRouter : NSObject
@property (nonatomic, readonly) NSArray<Class> *handlers;

+ (FBURLRouter *)sharedInstance;

- (void)addURLHandler:(Class)handler;
- (BOOL)canHandleURL:(NSString*)urlString;//all
- (BOOL)canHandleURL:(NSString*)urlString type:(FBURLHandlerType)type;
- (BOOL)canHandleURL:(NSString*)urlString type:(FBURLHandlerType)type handlerClass:(Class _Nullable *_Nullable)handlerClass;

- (void)handleURL:(NSString*)urlString;
- (void)handleURL:(NSString*)urlString navigation:(UINavigationController*)navigation;
- (void)handleURL:(NSString*)urlString navigation:(UINavigationController*)navigation handlerClass:(Class _Nullable *_Nullable)handlerClass;

- (void)handleURL:(NSString*)urlString navigation:(UINavigationController*)navigation type:(FBURLHandlerType)type;
- (void)handleURL:(NSString*)urlString navigation:(UINavigationController*)navigation type:(FBURLHandlerType)type handlerClass:(Class _Nullable *_Nullable)handlerClass;;

- (void)handleURL:(NSString*)urlString navigation:(UINavigationController*)navigation type:(FBURLHandlerType)type extra:(NSDictionary* _Nullable)extra;
- (void)handleURL:(NSString*)urlString navigation:(UINavigationController*)navigation type:(FBURLHandlerType)type extra:(NSDictionary* _Nullable)extra handlerClass:(Class _Nullable *_Nullable)handlerClass;
@end

NS_ASSUME_NONNULL_END
