//
//  KNConfigurationService.h
//  Telephaty
//
//  Created by PEDRO MUÑOZ CABRERA on 12/11/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Needed UUID for the service. This identifies the service to listen for app.
 */

#define TELEPHATY_SERVICE_UUID              @"00001101-0000-1000-8000-00805F9B34FB"

/**
 *  UUID for the characteristic where the app will write and send the message.
 */

#define TELEPHATY_CHARACTERISTIC_UUID       @"00001101-0000-1000-8000-00805F9B34FA"

/**
 *  Indicate how much old will be the messages that will be removed from DB periodically.
 */
#define REMOVE_MESSAGES_OLDER_THAN_MINUTES  15

@interface KNConfigurationService : NSObject

@end
