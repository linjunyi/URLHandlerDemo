//
//  FBURLRouter.m
//  FBAppContext
//
//  Created by KouJun on 2019/1/9.
//  Copyright © 2019 Fenbi. All rights reserved.
//

#import "FBURLRouter.h"
#import "FBURLHandlerProtocol.h"

NSString * const FBURLHandleResultCallbackKey = @"FBURLHandleResultCallbackKey";

@interface FBURLRouter () {
    NSMutableSet <Class<FBURLHandlerProtocol>> *_classes;
    NSMutableArray <id<FBURLHandlerProtocol>> *_instances;
}
@end

@implementation FBURLRouter

+ (FBURLRouter *)sharedInstance {
    static FBURLRouter *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[FBURLRouter alloc] init];
    });
    return _sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        _classes = [NSMutableSet set];
        _instances = [NSMutableArray array];
    }
    return self;
}

- (NSArray<Class>*)handlers {
    return _classes.allObjects;
}

- (void)addURLHandler:(Class)handler {
    [_classes addObject:handler];
}

- (id<FBURLHandlerProtocol>)handlerInstance:(Class)handler {
    for (id<FBURLHandlerProtocol> h in _instances) {
        if ([h isKindOfClass:handler]) {
            return h;
        }
    }

    id<FBURLHandlerProtocol> h = [[handler alloc] init];
    [_instances addObject:h];
    return h;
}

- (BOOL)canHandleURL:(NSString*)urlString {
    return [self canHandleURL:urlString type:FBURLHandlerTypeAll];
}

- (BOOL)canHandleURL:(NSString *)urlString type:(FBURLHandlerType)type {
    return [self canHandleURL:urlString type:type handler:nil parameters:nil toURL:nil matchedIndex:NULL];
}

- (BOOL)canHandleURL:(NSString*)urlString type:(FBURLHandlerType)type handlerClass:(Class*)handlerClass {
    return [self canHandleURL:urlString type:type handler:handlerClass parameters:nil toURL:nil matchedIndex:NULL];
}

- (BOOL)canHandleURL:(NSString*)urlString type:(FBURLHandlerType)type handler:(Class*)handler parameters:(NSMutableDictionary**)parameters toURL:(NSURL**)URL matchedIndex:(NSUInteger*)matchedIndex {
    if (![urlString isKindOfClass:[NSString class]]) {
        return NO;
    }

    for (Class<FBURLHandlerProtocol> h in _classes) {
        if ([h canHandleUrl:urlString type:type parameters:parameters toURL:URL matchedIndex:matchedIndex]) {
            if (handler) {
                *handler = h;
            }
            return YES;
        }
    }

    return NO;
}

- (void)handleURL:(NSString*)urlString {
    [self handleURL:urlString navigation:nil type:FBURLHandlerTypeAll extra:nil handlerClass:nil];
}

- (void)handleURL:(NSString*)urlString navigation:(UINavigationController*)navigation {
    [self handleURL:urlString navigation:navigation type:FBURLHandlerTypeAll extra:nil handlerClass:nil];
}


- (void)handleURL:(NSString*)urlString navigation:(UINavigationController*)navigation handlerClass:(Class _Nullable *_Nullable)handlerClass {
    [self handleURL:urlString navigation:navigation type:FBURLHandlerTypeAll extra:nil handlerClass:handlerClass];
}

- (void)handleURL:(NSString*)urlString navigation:(UINavigationController*)navigation type:(FBURLHandlerType)type {
    [self handleURL:urlString navigation:navigation type:type extra:nil handlerClass:nil];
}

- (void)handleURL:(NSString*)urlString navigation:(UINavigationController*)navigation type:(FBURLHandlerType)type handlerClass:(Class _Nullable *_Nullable)handlerClass {
    [self handleURL:urlString navigation:navigation type:type extra:nil handlerClass:handlerClass];
}

- (void)handleURL:(NSString*)urlString navigation:(UINavigationController*)navigation type:(FBURLHandlerType)type extra:(NSDictionary*)extra {
    [self handleURL:urlString navigation:navigation type:type extra:extra handlerClass:nil];
}

- (void)handleURL:(NSString*)urlString navigation:(UINavigationController*)navigation type:(FBURLHandlerType)type extra:(NSDictionary* _Nullable)extra handlerClass:(Class _Nullable *_Nullable)handlerClass {
    Class h;
    NSMutableDictionary *parameters;
    NSURL *URL;
    NSUInteger matchedIndex = 0;

    if([self canHandleURL:urlString type:type handler:&h parameters:&parameters toURL:&URL matchedIndex:&matchedIndex]) {
        if (h) {
            id<FBURLHandlerProtocol> handler = [self handlerInstance:h];
            [handler setMatchedPatternIndex:matchedIndex];
            if (extra) {
                if (!parameters) {
                    parameters = [NSMutableDictionary new];
                }
                [parameters addEntriesFromDictionary:extra];
            }

            [handler handleUrl:URL navi:navigation parameters:parameters];
        }
    }

    if (handlerClass) {
        *handlerClass = h;
    }
}

//- (BOOL)checkHaveConflict {
//    BOOL result = NO;
//    NSArray *classArray = [_classes allObjects];
//    NSUInteger count = [classArray count];
//
//    for (int i = 1; i < count; i++) {
//        for (int j = 0; j < i; j++) {
//            Class cur = classArray[i];
//            Class check = classArray[j];
//            if([cur isConflictWithHandler:check]) {
//                result = YES;
//                NSLog(@"URLHanlder class(%@) patterns conflict with class(%@)",NSStringFromClass(cur),NSStringFromClass(check));
//            }
//        }
//    }
//    return result;
//}

- (BOOL)shouldCreateNavigationControllerWhenHandlePush:(NSString *)urlString
{
    Class h;
    NSMutableDictionary *parameters;
    NSURL *URL;
    NSUInteger matchedIndex = 0;

    if ([self canHandleURL:urlString type:FBURLHandlerTypeAll handler:&h parameters:&parameters toURL:&URL matchedIndex:&matchedIndex]) {
        if (h) {
            if ([h respondsToSelector:@selector(shouldCreateNavigationControllerWhenHandlePush:patternIndex:)]) {
                return [h shouldCreateNavigationControllerWhenHandlePush:urlString patternIndex:matchedIndex];
            }
            else {
                return YES;
            }
        }
        else {
            return NO;
        }
    }
    else {
        return NO;
    }
}

@end
