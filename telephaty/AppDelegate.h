//
//  AppDelegate.h
//  Telephaty
//
//  Created by PEDRO MUÑOZ CABRERA on 12/11/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KNTelephatyService.h"

#import <Security/Security.h>

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


#pragma mark - Class methods

/**
 *  Singleton
 *
 *  @return Instance of AppDelegate
 */
+ (instancetype)sharedDelegate;

@end