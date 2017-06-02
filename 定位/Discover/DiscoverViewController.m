//
//  DiscoverViewController.m
//  定位
//
//  Created by 李自杨 on 2017/5/31.
//  Copyright © 2017年 View. All rights reserved.
//

/**<设置字体大小*///使用这种方式添加注释在调用时下方会自动显示注释

#import "DiscoverViewController.h"
#import <MapKit/MapKit.h>

@interface DiscoverViewController ()<MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;//地图

@property (nonatomic, strong) CLLocationManager *locationManager;


@end

@implementation DiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"发现";
    
    //获取定位服务授权
    [self requestUserLocationAuthor];
    
    //初始化地图视图
    [self initMapView];
    
}

-(void)requestUserLocationAuthor{
    //如果没有获取定位授权，获取定位授权请求
    self.locationManager = [[CLLocationManager alloc]init];
    //十米误差范围
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    if ([CLLocationManager locationServicesEnabled]) {
        if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
}

-(void)initMapView{
    //初始化地图
    _mapView = [[MKMapView alloc]initWithFrame:CGRectMake(0, 64, KWidth, KHeight - 64 - 49)];
    
//    1. MKMapView的显示项
    //设置地图类型
//    MKMapTypeStandard 标准
//    MKMapTypeSatellite 卫星
//    MKMapTypeHybrid 混合
//    MKMapTypeSatelliteFlyover 3D卫星(10_11, 9_0),
//    MKMapTypeHybridFlyover 3D混合(10_11, 9_0),
    _mapView.mapType = MKMapTypeStandard;
    
    //显示交通路线
    _mapView.showsTraffic = YES;
    
    //显示地图上的指南针
    _mapView.showsCompass = YES;
    
    //显示地图上的建筑物,只影响标准地图
    _mapView.showsBuildings = YES;
    
    //显示地图上的POI点
    _mapView.showsPointsOfInterest = YES;
    
    //显示地图上的缩放比例尺
    _mapView.showsScale = YES;
    
    //显示用户当前位置(如果不设置追踪模式，地图不会自动放大)
    _mapView.showsUserLocation = YES;
    
    //设置用户跟踪模式
    //    MKUserTrackingModeNone 不跟踪用户的位置
    //    MKUserTrackingModeFollow 跟踪用户的位置
    //    MKUserTrackingModeFollowWithHeading __TVOS_PROHIBITED 导航跟踪用户的位置和标题
    _mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;

    // 2. MKMapView的控制项
    //地图滚动
    _mapView.scrollEnabled = YES;
    //地图缩放
    _mapView.zoomEnabled = YES;
    //地图旋转
    _mapView.rotateEnabled = YES;
    //是否显示3D视角
    _mapView.pitchEnabled = YES;
    
    
    //代理
    _mapView.delegate = self;
    
    [self.view addSubview:_mapView];
    
}

#pragma mark -- MKMapViewDelegate
//跟踪到用户位置时会调用该方法
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{

    //创建编码对象
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    //反地理编码
    [geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error != nil || placemarks.count == 0) {
            return ;
        }
        //获取地标
        CLPlacemark *placemark = [placemarks firstObject];
        //设置标题
        userLocation.title = placemark.locality;
        //设置子标题
        userLocation.subtitle = placemark.name;
    }];
}


























@end
