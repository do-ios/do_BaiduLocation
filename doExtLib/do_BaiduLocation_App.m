//
//  do_BaiduLocation_App.m
//  DoExt_SM
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_BaiduLocation_App.h"
static do_BaiduLocation_App* instance;
@implementation do_BaiduLocation_App
@synthesize OpenURLScheme;
+(id) Instance
{
    if(instance==nil)
        instance = [[do_BaiduLocation_App alloc]init];
    return instance;
}
@end
