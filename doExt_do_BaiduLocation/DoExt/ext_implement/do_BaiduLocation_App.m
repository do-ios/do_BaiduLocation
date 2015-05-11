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
#import "BMapKit.h"
@interface do_BaiduLocation_App() <BMKGeneralDelegate>

@end

@implementation do_BaiduLocation_App
@synthesize ThridPartyID;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    BMKMapManager *_mapManager = [[BMKMapManager alloc]init];
    NSString *_BMKMapKey = [[doServiceContainer Instance].ModuleExtManage GetThirdAppKey:@"baiduLocationAppKey.plist" :@"baiduLocationAppKey" ];
    [_mapManager start:_BMKMapKey generalDelegate:self];
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
    
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    
}
@end
