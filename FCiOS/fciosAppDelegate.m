//
//  fciosAppDelegate.m
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/01/26.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import "fciosAppDelegate.h"
#import "MainViewController.h"
#import "SortConfigViewController.h"
#import "SettingViewController.h"

@implementation fciosAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    //ユーザーデフォルトに初期値を設定
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults setObject:@"1.0" forKey:DATABSEVERSION_KEY];
    [defaults setObject:@"0" forKey:DEFAULT_PLAYRANK_KEY];
    [defaults setObject:@"0" forKey:DEFAULT_PLAYSTYLE_KEY];
    [USER_DEFAULT registerDefaults:defaults];
    [USER_DEFAULT synchronize];
//    NSLog(@"%f",[USER_DEFAULT floatForKey:DATABSEVERSION_KEY]);
    
    UINavigationController *nvc1 = [[UINavigationController alloc] init];
    nvc1.navigationBar.barStyle = UIBarStyleBlack;
    UIViewController *viewController1 = [[MainViewController alloc] init];
    nvc1.viewControllers = @[viewController1];
    
    UINavigationController *nvc2 = [[UINavigationController alloc] init];
    nvc2.navigationBar.barStyle = UIBarStyleBlack;
    UIViewController *viewController2 = [[SortConfigViewController alloc] init];
    nvc2.viewControllers = @[viewController2];
    
    UINavigationController *nvc3 = [[UINavigationController alloc] init];
    nvc3.navigationBar.barStyle = UIBarStyleBlack;
    UIViewController *viewController3 = [[SettingViewController alloc] init];
    nvc3.viewControllers = @[viewController3];

    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[nvc1,nvc2,nvc3];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"update" ofType:@"json"];
//    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:path];
//    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
//    
//    DatabaseManager *dbManager = [DatabaseManager sharedInstance];
//    
////    NSLog(@"json %@",jsonObject);
//    for(NSDictionary *key in jsonObject){
////        NSLog(@"key = %@",key);
//        
//        //現在のバージョンより上だったらアップデート
//        if ([[key objectForKey:@"version"] floatValue] >= [USER_DEFAULT floatForKey:DATABSEVERSION_KEY]) {
//            NSLog(@"version %@",[key objectForKey:@"version"]);
//            NSLog(@"description%@",[key objectForKey:@"description"]);
//            //sqlのdictionaryを渡し、アップデート
//            [dbManager updateDatabase:[key objectForKey:@"sql"]];
//        }
//    }

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    DatabaseManager *dbManager = [DatabaseManager sharedInstance];
    if ([dbManager.music_DB open]) {
        [dbManager.music_DB executeUpdate:@"vacuum"];
        [dbManager.music_DB close];
    }
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
