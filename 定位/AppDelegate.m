//
//  AppDelegate.m
//  定位
//
//  Created by 李自杨 on 2017/5/31.
//  Copyright © 2017年 View. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "DiscoverViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    
    MainViewController *mainVC = [[MainViewController alloc]init];
    UINavigationController *mainNavi = [[UINavigationController alloc]initWithRootViewController:mainVC];
    mainNavi.tabBarItem.title = @"首页";
    mainNavi.tabBarItem.image = [ImageNamed(@"nav_icon_home_normal") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    mainNavi.tabBarItem.selectedImage = [ImageNamed(@"nav_icon_home_active")imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    DiscoverViewController *disVC = [[DiscoverViewController alloc]init];
    UINavigationController *disNavi = [[UINavigationController alloc]initWithRootViewController:disVC];
    disNavi.tabBarItem.title = @"发现";
    disNavi.tabBarItem.image = [ImageNamed(@"nav_icon_discover_normal") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    disNavi.tabBarItem.selectedImage = [ImageNamed(@"nav_icon_discover_active") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarController *tabBar = [[UITabBarController alloc]init];
    tabBar.viewControllers = @[mainNavi,disNavi];
    
    self.window.rootViewController = tabBar;

    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
