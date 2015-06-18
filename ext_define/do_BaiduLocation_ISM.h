//
//  do_BaiduLocation_IMethod.h
//  DoExt_SM
//
//  Created by guoxj on 15/4/8.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol do_BaiduLocation_ISM <NSObject>

@required
//实现同步或异步方法，parms中包含了所需用的属性
- (BOOL)start:(NSArray *)parms;
- (BOOL)stop:(NSArray *)parms;

@end