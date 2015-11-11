//
//  do_BaiduLocation_SM.h
//  DoExt_API
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_BaiduLocation_ISM.h"
#import "doSingletonModule.h"

@interface do_BaiduLocation_SM : doSingletonModule<do_BaiduLocation_ISM>
@property (assign, nonatomic) BOOL isLoop;
+ (void)startService;
@end