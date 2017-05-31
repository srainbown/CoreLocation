//
//  MainViewController.m
//  定位
//
//  Created by 李自杨 on 2017/5/31.
//  Copyright © 2017年 View. All rights reserved.
//

#import "MainViewController.h"
#import <CoreLocation/CoreLocation.h>

/*
 <!-- 位置 -->
 <key>NSLocationUsageDescription</key>
 <string>App需要您的同意,才能访问位置</string>
 <!-- 在使用期间访问位置 -->
 <key>NSLocationWhenInUseUsageDescription</key>
 <string>App需要您的同意,才能在使用期间访问位置</string>
 <!-- 始终访问位置 -->
 <key>NSLocationAlwaysUsageDescription</key>
 */

/*
 1.重要方法:
         代码: - (CLLocationDistance)distanceFromLocation:(CLLocation *)location
         作用: 计算两个位置对象之间的物理距离, 单位是(米)
 2.注意事项:
         使用位置前, 务必判断当前获取的位置是否有效.
         代码: if (location.horizontalAccuracy < 0) return;
         功能: 如果水平精确度小于零, 代表虽然可以获取位置对象, 但是数据错误, 不可用
 
 经验小结:
        1.定位的应用场景
             1) 导航
             2) 电商APP,获取用户所在城市(需要与(反)地理编码联合使用)
             3) 数据采集用户信息(例如,统计app使用分布)
             4) 查找周边(周边好友, 周边商家等等)
        2.开发经验
             由于定位非常耗电; 所以为了给用户省电, 你可以遵守以下小经验
             1）不需要获取用户位置时,一定要关闭定位服务：
             2）如果能满足项目需求,尽可能的使用”监听显著位置变化”的定位服务(打车app)
             3）如果可以,尽可能使用低精度的desiredAccuracy
             4）如果是数据采集,(一般都是周期性的去轮询用户位置),在轮询期间一定要关闭定位
 */


@interface MainViewController ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *manager;

@property (nonatomic, strong) UIImageView *compassView;//指南针图片

@property (nonatomic, strong) CLGeocoder *geoC;//地理编码器

@property (nonatomic, strong) UILabel *clLabel;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"首页";

    //请求使用期间定位授权
    [self.manager requestWhenInUseAuthorization];
    //请求始终定位授权
//    [self.manager requestAlwaysAuthorization];
    //获取单次位置信息
//    [self.manager requestLocation];
    

    
    // 获取设备朝向前, 先判断"磁力计"是否可用
    if ([CLLocationManager headingAvailable]) {
//        获取设备朝向
        [self.manager startUpdatingHeading];
    }
    
    //开始更新用户的位置信息
    [self.manager startUpdatingLocation];
   
}

#pragma mark -- 懒加载
//创建CLLocationManager对象并设置代理
-(CLLocationManager *)manager{
    if (_manager == nil) {
        _manager = [[CLLocationManager alloc]init];
        _manager.delegate = self;
    }
    return _manager;
}
//创建CLGeocoder对象
-(CLGeocoder *)geoC{
    if (_geoC == nil) {
        _geoC = [[CLGeocoder alloc]init];
    }
    return _geoC;
}
-(UILabel *)clLabel{
    if (_clLabel == nil) {
        _clLabel = [[UILabel alloc]init];
        [self.view addSubview:_clLabel];
        [_clLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.view);
            make.left.mas_equalTo(20 * KWidthScale);
            make.right.mas_equalTo(-20 * KWidthScale);
        }];
        _clLabel.textAlignment = NSTextAlignmentCenter;
        _clLabel.textColor = [UIColor orangeColor];
        _clLabel.numberOfLines = 0;
        
    }
    return _clLabel;
}


#pragma mark -- CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"获取单次位置信息");
    /*
     实现逻辑:
        1.按照定位精确度从低到高进行排序,逐个进行定位,如果在有效时间内,定位到了精确度最好的位置,那么就把对应的位置通过代理告知外界.
        2.如果获取到的位置不是精确度最高的那个,也会在定位超时后,通过代理告诉外界.
     注意事项:
        1.必须实现代理的-locationManager:didFailWithError:方法.
        2.不用与startUpdatingLocation方法同时使用.
     */
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    NSLog(@"每当请求到位置信息时，都会调用此方法");
    CLLocation *loc = [locations lastObject];
    if (loc.horizontalAccuracy < 0) {
        return;
    }
  
    [self.geoC reverseGeocodeLocation:loc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count > 0) {
    
            //模拟器始终显示为苹果总部地址
            //包含区,街道等信息的地标对象
            CLPlacemark *placeMark = [placemarks lastObject];
            //城市名称 (四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）)
            NSString *city = placeMark.locality;
            //街道名称
            NSString *street = placeMark.thoroughfare;
            //全称
            NSString *name = placeMark.name;
            self.clLabel.text = [NSString stringWithFormat:@" 城市 : %@ , 街道 : %@ , 全称 : %@ ",city,street,name];
        }
    }];
    
    // locations: 按时间先后顺序排序
    /**
     *  coordinate : 经纬度
     *  altitude : 海拔
     *  horizontalAccuracy : 水平精确度, 如果是负数, 就代表这个location位置无效
     *  verticalAccuracy : 垂直精确度, 如果是负数, 就代表海拔没有用
     *  course : 航向
     *   0.0 - 359.9 degrees, 0 being true North
     *  speed : 速度
     *  distanceFromLocation : 计算两个坐标之间的物理直线距离
     */
    
//    CLLocation *loc = [locations lastObject];
//    if (loc.horizontalAccuracy < 0) {
//        return;
//    }
//    
//    // 场景演示
//    //   >场景演示:打印当前用户的行走方向,偏离角度以及对应的行走距离,
//    //   例如:”北偏东 30度 方向,移动了 8 米”
//    
//    // 1. 行走方向(北偏东, 东偏南)
//    NSArray *angleStrArr = @[@"北偏东", @"东偏南", @"南偏西", @"西偏北"];
//    NSInteger index = (NSInteger)loc.course / 90;
//    NSString *angStr = angleStrArr[index];
//    
//    // 2. 偏离角度(30)
//    NSInteger angle = (NSInteger)loc.course % 90;
//    
//    if (angle == 0)
//    {
//        // "东"
//        angStr = [@"正" stringByAppendingString:[angStr substringToIndex:1]];
//    }
//    
//    
//    // 3. 行走距离
//    
//    CLLocationDistance distance = 0;
//    if (_lastLocation) {
//        distance = [loc distanceFromLocation:_lastLocation];
//    }
//    _lastLocation = loc;
//    
//    // 4. 拼串打印
//    //   例如:”北偏东 30度 方向,移动了 8 米”
//    NSString *notice;
//    if (angle == 0) {
//        notice = [NSString stringWithFormat:@"%@方向, 行走了%f米", angStr, distance];
//    }else
//    {
//        notice = [NSString stringWithFormat:@"%@%zd度方向, 行走了%f米", angStr,angle, distance];
//    }
//    
//    NSLog(@"%@", notice);
//    
//    NSLog(@"定位到了---%@", loc);
}

//用户授权监听
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{

    switch (status) {
            
        case kCLAuthorizationStatusNotDetermined:{//用户还未决定
            NSLog(@"用户还未决定");
            break;
        }
        case kCLAuthorizationStatusRestricted:{//访问受限
            NSLog(@"访问受限");
            break;
        }
        case kCLAuthorizationStatusDenied:{//定位关闭时和对此APP授权为never时调用
            if ([CLLocationManager locationServicesEnabled]) {
                
                NSLog(@"定位开启,但被拒");
                //在此处，一般提醒用户给此应用授权，并跳转到"设置"界面让用户进行授权(这里只是跳转的关键代码)
                //在iOS8之后跳转到"设置"界面代码
                NSURL *settingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                
                if ([[UIApplication sharedApplication]canOpenURL:settingURL]) {//如果能跳转到设置
                    
                    [[UIApplication sharedApplication]openURL:settingURL];//就跳转到设置
                    
                }else{//如果不能
                    NSLog(@"定位关闭,不可用");
                }
                
            }
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:{
            NSLog(@"始终获取定位授权");
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:{
            NSLog(@"获取使用时定位授权");
            break;
        }
            
        default:
            break;
    }
    
}

//获取设置朝向信息(主要用于指南针,地图导航)
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    //旋转图片代码
    // 1.判断当前的角度是否有效(如果此值小于0,代表角度无效)
    if(newHeading.headingAccuracy < 0)
        return;
    
    // 2.获取当前设备朝向(磁北方向)
//    磁北角度: newHeading.magneticHeading   ------- 相对于"磁北方向"产生的角度
//    真北角度: newHeading.trueHeading           ------- 相对于"真北方向"产生的角度
    CGFloat angle = newHeading.magneticHeading;
    
    // 3.转换成为弧度
    CGFloat radian = angle / 180.0 * M_PI;
    
    // 4.带动画反向旋转指南针
    [UIView animateWithDuration:0.5 animations:^{
        self.compassView.transform = CGAffineTransformMakeRotation(-radian);
    }];
    
    /*
     注意事项:
         1. 获取设备朝向前, 先判断"磁力计"是否可用
         [CLLocationManager headingAvailable];
         
         2. 获取朝向前, 判断当前朝向信息是否有效
         if(newHeading.headingAccuracy < 0) return;
         
         3. 注意与"航向"的区别
         设备朝向是指手机的朝向; "航向"可以理解为设备的移动方向
         
         4. 使用"磁力计"传感器获取设备朝向, 不需要请求用户授权
         因为设备朝向不涉及用户隐私
     */
    
}



@end
