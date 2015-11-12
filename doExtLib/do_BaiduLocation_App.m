//
//  TYPEID_App.m
//  DoExt_SM
//
//  Created by guoxj on 15/4/8.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_BaiduLocation_App.h"
#import "doIModuleExtManage.h"
#import "doServiceContainer.h"
#import "do_BaiduLocation_SM.h"
#import "doScriptEngineHelper.h"
#import <objc/runtime.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>

@class do_BaiduLocation_App;
static do_BaiduLocation_App * instance;
@interface do_BaiduLocation_App() <BMKGeneralDelegate>

@end

@implementation do_BaiduLocation_App
@synthesize OpenURLScheme;
+ (instancetype) Instance
{
    if (instance == nil) {
        instance = [[do_BaiduLocation_App alloc]init];
    }
    return instance;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    BMKMapManager *_mapManager = [[BMKMapManager alloc]init];
    NSString *_BMKMapKey = [[doServiceContainer Instance].ModuleExtManage GetThirdAppKey:@"baiduLocationAppKey.plist" :@"baiduLocationAppKey" ];
    NSString *isStart =  objc_getAssociatedObject(application, "BaiduMapView");
    objc_setAssociatedObject(application, "BaiduLocation", @"start", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (![isStart isEqualToString:@"start"]) {
        [_mapManager start:_BMKMapKey generalDelegate:nil];
    }
    return YES;
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url fromThridParty:(NSString *)_id
{
    return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation fromThridParty:(NSString *)_id
{
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    do_BaiduLocation_SM *baidu = (do_BaiduLocation_SM*)[doScriptEngineHelper ParseSingletonModule:nil :@"do_BaiduLocation"];
    if (baidu.isLoop) {
        [baidu startService];
    }
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    
}
@end
