//
//  do_BaiduLocation_SM.m
//  DoExt_SM
//
//  Created by guoxj on 15/4/8.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_BaiduLocation_SM.h"

#import "doScriptEngineHelper.h"
#import "doIScriptEngine.h"
#import "doInvokeResult.h"
#import "doJsonHelper.h"
#import "BMapKit.h"
@interface do_BaiduLocation_SM() <do_BaiduLocation_ISM, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate>
@end
static do_BaiduLocation_SM *_baiduLocation;
NSString *_model;
BMKLocationService *_locService;
BMKGeoCodeSearch *_geocodesearch;

@implementation do_BaiduLocation_SM
{

    CLLocationCoordinate2D _coordinate;
    NSDictionary *_dictParas;
    id<doIScriptEngine> _scritEngine;
    NSString *_callbackName;

}

#pragma mark -
#pragma mark - 同步异步方法的实现
/*
 1.参数节点
     doJsonNode *_dictParas = [parms objectAtIndex:0];
     a.在节点中，获取对应的参数
     NSString *title = [_dictParas GetOneText:@"title" :@"" ];
     说明：第一个参数为对象名，第二为默认值
 
 2.脚本运行时的引擎
     id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
 
 同步：
 3.同步回调对象(有回调需要添加如下代码)
     doInvokeResult *_invokeResult = [parms objectAtIndex:2];
     回调信息
     如：（回调一个字符串信息）
     [_invokeResult SetResultText:((doUIModule *)_model).UniqueKey];
 异步：
 3.获取回调函数名(异步方法都有回调)
     NSString *_callbackName = [parms objectAtIndex:2];
     在合适的地方进行下面的代码，完成回调
     新建一个回调对象
     doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
     填入对应的信息
     如：（回调一个字符串）
     [_invokeResult SetResultText: @"异步方法完成"];
     [_scritEngine Callback:_callbackName :_invokeResult];

 */
+ (void)startService
{
    if ([_model isEqualToString:@"high"])
    {
        [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyBest];
        [BMKLocationService setLocationDistanceFilter:10.f];
    }
    else if ([_model isEqualToString:@"low"])
    {
        [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyThreeKilometers];
        [BMKLocationService setLocationDistanceFilter:1000.f];
    }
    else if ([_model isEqualToString:@"middle"])
    {
        [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        [BMKLocationService setLocationDistanceFilter:100.f];
    }
    
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    [_locService startUserLocationService];
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    _geocodesearch.delegate = self;
}

//同步
/**
 *停止定位
 */
 - (BOOL)stop:(NSArray *)parms
 {
//     doJsonNode *_dictParas = [parms objectAtIndex:0];
//     id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
//     //自己的代码实现
     [_locService stopUserLocationService];
     return YES;
 }
//异步
/**
 *启动定位服务
 */
- (BOOL)start:(NSArray *)parms
{
    _dictParas = [parms objectAtIndex:0];
//    _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    
//    _callbackName = [parms objectAtIndex:2];
    _model = [doJsonHelper GetOneText:_dictParas :@"model" :@"high"];
    if ([_model isEqualToString:@"high"])
    {
        [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyBest];
        [BMKLocationService setLocationDistanceFilter:10.f];
    }
    else if ([_model isEqualToString:@"low"])
    {
        [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyThreeKilometers];
        [BMKLocationService setLocationDistanceFilter:1000.f];
    }
    else if ([_model isEqualToString:@"middle"])
    {
        [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        [BMKLocationService setLocationDistanceFilter:100.f];
    }
    
    // 是否循环不停的获取
    self.isLoop = [doJsonHelper GetBoolean:_dictParas :NO];
//    [BMKLocationService setLocationDistanceFilter:1000.f];
    
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    [_locService startUserLocationService];
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    _geocodesearch.delegate = self;
    return YES;
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    _coordinate.latitude  = userLocation.location.coordinate.latitude;
    _coordinate.longitude = userLocation.location.coordinate.longitude;
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = _coordinate;
    
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
    
}

/**
 *在停止定位后，会调用此函数
 */
- (void)didStopLocatingUser
{
    
}

/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    
}

/**
 *返回地址信息搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结BMKGeoCodeSearch果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == 0) {
        BMKPointAnnotation *_pointAnnotation = [[BMKPointAnnotation alloc]init];
        _pointAnnotation.coordinate = result.location;
        _pointAnnotation.title = result.address;
        
        NSMutableDictionary *_dict = [[NSMutableDictionary alloc]init];
//        [_dict setValue:@"bd-0911" forKey:@"type"];
        [_dict setValue:[NSString stringWithFormat:@"%f",_pointAnnotation.coordinate.latitude] forKey:@"latitude"];
        [_dict setValue:[NSString stringWithFormat:@"%f",_pointAnnotation.coordinate.longitude] forKey:@"longitude"];
        [_dict setValue:_pointAnnotation.title forKey:@"address"];
        doInvokeResult *_invokeResult = [[doInvokeResult alloc] init:nil];
        [_invokeResult SetResultNode: _dict];
//        [_scritEngine Callback:_callbackName :_invokeResult];
        [self.EventCenter FireEvent:@"result" :_invokeResult];
    }
    if (!self.isLoop)
    {
        [_locService stopUserLocationService];
    }
}

/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == 0) {
        BMKPointAnnotation* _pointAnnotation = [[BMKPointAnnotation alloc]init];
        _pointAnnotation.coordinate = result.location;
        _pointAnnotation.title = result.address;
        NSMutableDictionary *_dict = [[NSMutableDictionary alloc]init];
//        [_dict setValue:@"bd-0911" forKey:@"type"];
        [_dict setValue:[NSString stringWithFormat:@"%f",_pointAnnotation.coordinate.latitude] forKey:@"latitude"];
        [_dict setValue:[NSString stringWithFormat:@"%f",_pointAnnotation.coordinate.longitude] forKey:@"longitude"];
        [_dict setValue:_pointAnnotation.title forKey:@"address"];
        doInvokeResult *_invokeResult = [[doInvokeResult alloc] init:nil];
        [_invokeResult SetResultNode: _dict];
//        [_scritEngine Callback:_callbackName :_invokeResult];
        [self.EventCenter FireEvent:@"result" :_invokeResult];
    }
    if (!self.isLoop)
    {
        [_locService stopUserLocationService];
    }
}

- (void)Dispose
{
    _locService = nil;
    _geocodesearch = nil;
}

@end