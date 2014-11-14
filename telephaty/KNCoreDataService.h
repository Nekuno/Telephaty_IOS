//
//  KNCoreDataService.h
//  Telephaty
//
//  Created by PEDRO MUÑOZ CABRERA on 12/11/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  KNCoreDataService
 */
@interface KNCoreDataService : NSObject


/**
 *  Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;


// Return the unique instance of this class (Singleton).

/**
 *  Return the unique instance of this class (Singleton).
 */

+ (id)sharedInstance;

/**
 *  Save content of Data base to disk.
 */
- (void)saveContext;

@end
