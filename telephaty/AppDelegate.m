//
//  AppDelegate.m
//  Telephaty
//
//  Created by Eduardo Palenzuela Darias on 01/10/14.
//  Copyright (c) 2014 kiliannet. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.

  [self.telephatyService startEmit];
  [self.telephatyService startWatch];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Properties

@synthesize mainStoryboard = _mainStoryboard;
- (UIStoryboard *)mainStoryboard {
  // Init
  if (!_mainStoryboard) {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _mainStoryboard = storyboard;
  }
  
  return _mainStoryboard;
}

@synthesize telephatyService = _telephatyService;
- (KNTelephatyService *)telephatyService {
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    _telephatyService = [[KNTelephatyService alloc] init];
  });
  
  return _telephatyService;
}

@synthesize coreDataService = _coreDataService;
- (KNCoreDataService *)coreDataService {
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    _coreDataService = [[KNCoreDataService alloc] init];
  });
  
  return _coreDataService;
}

#pragma mark - Public

+ (instancetype)sharedDelegate {
  static AppDelegate *instance;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    instance = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  });
  
  return instance;
}

@end
