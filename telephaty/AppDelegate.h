//
//  AppDelegate.h
//  Telephaty
//
//  Created by Eduardo Palenzuela Darias on 01/10/14.
//  Copyright (c) 2014 kiliannet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KNTelephatyService.h"
#import "KNCoreDataService.h"

#define COLOR_TINT [UIColor colorWithRed:0.0f/255.0f green:121.0f/255.0f blue:255.0f/255.0f alpha:1.0f]

@interface AppDelegate : UIResponder <UIApplicationDelegate>

#pragma mark - Properties

/**
 *  UIApplicationDelegate
 */
@property (strong, nonatomic) UIWindow *window;

/**
 *  MainStoryboard
 */
@property (strong, nonatomic, readonly) UIStoryboard *mainStoryboard;

/**
 *  KNTelephatyService
 */
@property (strong, nonatomic, readonly) KNTelephatyService *telephatyService;

/**
 *  KNCoreDataService
 */
@property (strong, nonatomic, readonly) KNCoreDataService *coreDataService;

#pragma mark - Class methods

/**
 *  Singleton
 *
 *  @return Instance of AppDelegate
 */
+ (instancetype)sharedDelegate;

@end