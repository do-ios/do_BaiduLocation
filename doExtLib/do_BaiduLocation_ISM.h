//
//  do_BaiduLocation_IMethod.h
//  DoExt_API
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol do_BaiduLocation_ISM <NSObject>

//实现同步或异步方法，parms中包含了所需用的属性
@required
- (void)start:(NSArray *)parms;
- (void)stop:(NSArray *)parms;
- (void)getDistance:(NSArray *)parms;
- (void)locate:(NSArray *)parms;
- (void)startScan:(NSArray *)parms;
- (void)stopScan:(NSArray *)parms;
@end