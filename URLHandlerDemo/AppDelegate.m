//
//  AppDelegate.m
//  URLHandleDemo
//
//  Created by 林君毅 on 2025/4/18.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "AutoRegURLHandler.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:[ViewController new]];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = navi;
    [self.window makeKeyAndVisible];
    
    [[FBURLRouter sharedInstance] addURLHandler:[AutoRegURLHandler class]];
#ifdef DEBUG
    NSString *errorString = nil;
    BOOL urlValid = [AutoRegURLHandler checkValid:&errorString];
    NSAssert(urlValid, errorString);
#endif
    
    return YES;
}

@end
