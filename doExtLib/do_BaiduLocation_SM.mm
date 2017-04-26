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

#import <BaiduMapAPI_Base/BMKBaseComponent.h>

#import <BaiduMapAPI_Location/BMKLocationComponent.h>

#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>

#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <BaiduMapAPI_Search/BMKPoiSearchType.h>
@interface do_BaiduLocation_SM() <do_BaiduLocation_ISM, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate>

@end

NSString *_model;
BMKLocationService *_locService;
BMKGeoCodeSearch *_geocodesearch;

@implementation do_BaiduLocation_SM
{
    
    CLLocationCoordinate2D _coordinate;
    NSDictionary *_dictParas;
    id<doIScriptEngine> _locateScritEngine;
    id<doIScriptEngine> _geoscritEngine;
    id<doIScriptEngine> _reverseScritEngine;
    NSString *_callbackName;
    
    BOOL _isScan;
    BOOL _isStart;
    //调用locate方法
    BOOL _isLocating;
}
- (instancetype)init
{
    self = [super init];
    _isScan = NO;
    _isStart = NO;
    _isLocating = NO;
    return self;
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

//同步
/**
 *停止定位
 */
- (void)stop:(NSArray *)parms
{
    [_locService stopUserLocationService];
    _locService.delegate = nil;
    _locService = nil;
    _geocodesearch.delegate = nil;
    _geocodesearch = nil;
    _isStart = NO;
}
//异步
/**
 *启动定位服务
 */
- (void)start:(NSArray *)parms
{
    _dictParas = [parms objectAtIndex:0];
    if (!_locService) {
       _locService = [[BMKLocationService alloc]init];
        _locService.delegate = self;
    }
    
    [_locService startUserLocationService];
    if (!_geocodesearch) {
        _geocodesearch = [[BMKGeoCodeSearch alloc]init];
        _geocodesearch.delegate = self;
    }
    
    _model = [doJsonHelper GetOneText:_dictParas :@"model" :@"high"];
    if ([_model isEqualToString:@"high"])
    {
        _locService.desiredAccuracy = kCLLocationAccuracyBest;
        _locService.distanceFilter = 10.f;
    }
    else if ([_model isEqualToString:@"low"])
    {
        _locService.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        _locService.distanceFilter = 1000.f;
    }
    else if ([_model isEqualToString:@"middle"])
    {
        _locService.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        _locService.distanceFilter = 100.f;
    }
    
    // 是否循环不停的获取
    _isStart = YES;
    self.isLoop = [doJsonHelper GetOneBoolean:_dictParas :@"isLoop" :NO];
}

- (void)startService
{
    if ([_model isEqualToString:@"high"])
    {
        _locService.desiredAccuracy = kCLLocationAccuracyBest;
        _locService.distanceFilter = 10.f;
    }
    else if ([_model isEqualToString:@"low"])
    {
        _locService.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        _locService.distanceFilter = 1000.f;
    }
    else if ([_model isEqualToString:@"middle"])
    {
        _locService.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        _locService.distanceFilter = 100.f;
    }
    if (_locService == nil) {
        _locService = [[BMKLocationService alloc]init];
        _locService.delegate = self;
        [_locService startUserLocationService];
        _geocodesearch = [[BMKGeoCodeSearch alloc]init];
        _geocodesearch.delegate = self;
    }
}
- (void)getDistance:(NSArray *)parms
{
    NSDictionary *dictParas = [parms objectAtIndex:0];
    //自己的代码实现
    NSString *startPoint = [doJsonHelper GetOneText:dictParas :@"startPoint" :@""];
    NSString *endPoint = [doJsonHelper GetOneText:dictParas :@"endPoint" :@""];
    NSArray *starts = [startPoint componentsSeparatedByString:@","];
    NSArray *ends = [endPoint componentsSeparatedByString:@","];
    BMKMapPoint point1 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake([[starts firstObject] floatValue],[[starts lastObject]floatValue]));
    BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake([[ends firstObject] floatValue],[[ends lastObject]floatValue]));
    CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    [_invokeResult SetResultFloat:distance];
    //_invokeResult设置返回值
}
- (void)startScan:(NSArray *)parms
{
    _isScan = YES;
    [self beginLocation:parms];
}
- (void)stopScan:(NSArray *)parms
{
    [_locService stopUserLocationService];
    _locService.delegate = nil;
    _locService = nil;
    _geocodesearch.delegate = nil;
    _geocodesearch = nil;
    _isScan = NO;
}
- (void)locate:(NSArray *)parms
{
    
    _isScan = NO;
    _isLocating = YES;
    _locateScritEngine = [parms objectAtIndex:1];
    _callbackName = [parms objectAtIndex:2];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self beginLocation:parms];
        
        //拒绝授权
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||[CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            doInvokeResult *result = [[doInvokeResult alloc]init:self.UniqueKey];
            [result SetResultText:@"定位权限被拒绝,请在隐私设置中开启"];
            [_locateScritEngine Callback:_callbackName :result];
            return;
        }
        
    });
}
- (void)geoCode:(NSArray *)parms
{
    _dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    _geoscritEngine = [parms objectAtIndex:1];
    _callbackName = [parms objectAtIndex:2];
    NSString *city = [doJsonHelper GetOneText:_dictParas :@"city" :@""];
    NSString *address = [doJsonHelper GetOneText:_dictParas :@"address" :@""];
    if (!_geocodesearch) {
        _geocodesearch = [[BMKGeoCodeSearch alloc]init];
        _geocodesearch.delegate = self;
    }
    BMKGeoCodeSearchOption *option = [[BMKGeoCodeSearchOption alloc]init];
    option.city = city;
    option.address = address;
    [_geocodesearch geoCode:option];
    
}

- (void)reverseGeoCode:(NSArray *)parms
{
    _dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    _reverseScritEngine = [parms objectAtIndex:1];
    _callbackName = [parms objectAtIndex:2];
    doInvokeResult *invokeResult = [[doInvokeResult alloc] init];
    NSMutableDictionary *resultNode = [NSMutableDictionary dictionary];
    
    if (!_geocodesearch) {
        _geocodesearch = [[BMKGeoCodeSearch alloc]init];
        _geocodesearch.delegate = self;
    }
    
    NSString *latitude = [doJsonHelper GetOneText:_dictParas :@"latitude" :@""];
    NSString *longitude = [doJsonHelper GetOneText:_dictParas :@"longitude" :@""];
    BMKReverseGeoCodeOption *option = [[BMKReverseGeoCodeOption alloc]init];
    
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(latitude.floatValue, longitude.floatValue);
    option.reverseGeoPoint = coor;
    
    [_geocodesearch reverseGeoCode:option];
    
}
#pragma mark - 私有方法
- (void)beginLocation:(NSArray *)parms
{
    _dictParas = [parms objectAtIndex:0];
    if (!_locService) {
        _locService = [[BMKLocationService alloc]init];
        _locService.delegate = self;
    }
    _model = [doJsonHelper GetOneText:_dictParas :@"model" :@"high"];
    if (_model.length < 2) {
        _model = @"high";
    }
    if ([_model isEqualToString:@"high"])
    {
        _locService.desiredAccuracy = kCLLocationAccuracyBest;
        _locService.distanceFilter = 10.f;
    }
    else if ([_model isEqualToString:@"low"])
    {
        _locService.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        _locService.distanceFilter = 1000.f;
    }
    else if ([_model isEqualToString:@"middle"])
    {
        _locService.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        _locService.distanceFilter = 100.f;
    }
    [_locService startUserLocationService];
}
#pragma mark - BMKLocationServiceDelegate方法
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
    if (!_geocodesearch) {
        _geocodesearch = [[BMKGeoCodeSearch alloc]init];
        _geocodesearch.delegate = self;
    }
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

#pragma mark - BMKGeoCodeSearchDelegate方法
/**
 *返回地址信息搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结BMKGeoCodeSearch果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == 0) {
        //地理编码回调
        NSMutableDictionary *node = [NSMutableDictionary dictionary];
        [node setValue:[NSString stringWithFormat:@"%f",result.location.latitude] forKey:@"latitude"];
        [node setValue:[NSString stringWithFormat:@"%f",result.location.longitude] forKey:@"longitude"];
        doInvokeResult *invokeResult = [[doInvokeResult alloc]init];
        [invokeResult SetResultNode:node];
        [_geoscritEngine Callback:_callbackName :invokeResult];
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
    NSMutableDictionary *_dict = [[NSMutableDictionary alloc]init];
    [_dict setValue:[NSString stringWithFormat:@"%f",result.location.latitude] forKey:@"latitude"];
    [_dict setValue:[NSString stringWithFormat:@"%f",result.location.longitude] forKey:@"longitude"];
    [_dict setValue:result.address forKey:@"address"];
    if (error == 0) {
        if (_isStart) {
            doInvokeResult *_invokeResult = [[doInvokeResult alloc] init:nil];
            [_invokeResult SetResultNode: _dict];
            [self.EventCenter FireEvent:@"result" :_invokeResult];
        }
        if (_isScan) {//result事件
            doInvokeResult *_invokeResult = [[doInvokeResult alloc] init:nil];
            [_invokeResult SetResultNode: _dict];
            [self.EventCenter FireEvent:@"result" :_invokeResult];
        }
        if (_isLocating) {
            doInvokeResult *result = [[doInvokeResult alloc]init:self.UniqueKey];
            [result SetResultNode:_dict];
            [_locateScritEngine Callback:_callbackName :result];
            _isLocating = NO;
        }
        else{
            //地理编码回调
            if (_reverseScritEngine) {
                NSMutableDictionary *node = [NSMutableDictionary dictionary];
                [node setObject:result.address forKey:@"address"];
                [node setObject:result.addressDetail.province forKey:@"province"];
                [node setObject:result.addressDetail.city forKey:@"city"];
                [node setObject:result.addressDetail.district forKey:@"district"];
                [node setObject:result.addressDetail.streetName forKey:@"streetName"];
                [node setObject:result.addressDetail.streetNumber forKey:@"streetNumber"];
                NSMutableArray *poiList = [NSMutableArray array];
                for (BMKPoiInfo  *poiInfo in result.poiList) {
                    NSMutableDictionary *pointDict = [NSMutableDictionary dictionary];
                    [pointDict setValue:poiInfo.uid forKey:@"id"];
                    [pointDict setValue:poiInfo.name forKey:@"name"];
                    [pointDict setValue:poiInfo.city forKey:@"city"];
                    [pointDict setValue:[NSNumber numberWithBool:poiInfo.panoFlag] forKey:@"isPano"];
                    
                    NSMutableDictionary *locationDict = [NSMutableDictionary dictionary];
                    [locationDict setValue:[NSNumber numberWithDouble:poiInfo.pt.latitude] forKey:@"latitude"];
                    [locationDict setValue:[NSNumber numberWithDouble:poiInfo.pt.longitude] forKey:@"longitude"];
                    [pointDict setValue:locationDict forKey:@"location"];
                    
                    [pointDict setValue:poiInfo.address forKey:@"address"];
                    
                    [poiList addObject:pointDict];
                }
                [node setObject:poiList forKey:@"pois"];
                doInvokeResult *invokeResult = [[doInvokeResult alloc]init];
                [invokeResult SetResultNode:node];
                [_reverseScritEngine Callback:_callbackName :invokeResult];
                _reverseScritEngine = nil;
            }
        }
    }
    if (!self.isLoop)
    {
        [self stop:nil];
    }
    if (!_isScan) {
        [self stopScan:nil];
    }
}

- (void)Dispose
{
    _locService = nil;
    _geocodesearch = nil;
}

@end
