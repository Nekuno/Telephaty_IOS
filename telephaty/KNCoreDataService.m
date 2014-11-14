//
//  KNCoreDataService.m
//  Telephaty
//
//  Created by Eduardo K. Palenzuela Darias on 15/10/14.
//  Copyright (c) 2014 kiliannet. All rights reserved.
//

#import "KNCoreDataService.h"

#import <CoreData/CoreData.h>

#define DATABASE_NAME @"TelephatyDB"

@interface KNCoreDataService()

/**
 *  Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
@property (strong, nonatomic, readonly) NSManagedObjectModel *managedObjectModel;

/**
 *  Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
@property (strong, nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

/**
 *  KNCoreDataService
 */
@implementation KNCoreDataService


#pragma mark - Singleton

  static KNCoreDataService *sharedInstance;

+ (id)sharedInstance {
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    sharedInstance = [[KNCoreDataService alloc] init];
  });
  
  return sharedInstance;
}

+ (id)alloc
{
  @synchronized(self)
  {
    NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton KNCoreDataService.");
    sharedInstance = [super alloc];
  }
  
  return sharedInstance;
}

- (id) init
{
  if ((self = [super init])){
    //
  }
  return self;
}

#pragma mark - Properties

@synthesize managedObjectContext = _managedObjectContext;
- (NSManagedObjectContext *)managedObjectContext {
  if (_managedObjectContext != nil) {
    return _managedObjectContext;
  }
  
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  
  if (coordinator != nil) {
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
  }
  
  return _managedObjectContext;
}

@synthesize managedObjectModel = _managedObjectModel;
- (NSManagedObjectModel *)managedObjectModel {
  if (_managedObjectModel != nil) {
    return _managedObjectModel;
  }
  
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:DATABASE_NAME withExtension:@"momd"];
  _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  
  return _managedObjectModel;
}

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
  if (_persistentStoreCoordinator != nil) {
    return _persistentStoreCoordinator;
  }
  
  
  NSURL *storeURL = [[self applicationDocumentsDirectory]
                     URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", DATABASE_NAME]];
  NSError *error = nil;
  
  _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
  
  // Agregamos estas opciones para permitir migración ligera (modificaciones simples en el modelo de datos a través de versiones)
  NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                            NSInferMappingModelAutomaticallyOption: @YES,
                            NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"}};
  
  if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
    /*
     Replace this implementation with code to handle the error appropriately.
     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
     
     Typical reasons for an error here include:
     * The persistent store is not accessible;
     * The schema for the persistent store is incompatible with current managed object model.
     Check the error message to determine what the actual problem was.
     
     If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
     
     If you encounter schema incompatibility errors during development, you can reduce their frequency by:
     * Simply deleting the existing store:
     [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
     
     * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
     @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
     
     Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
     */
    
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
#if DEBUG
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
    abort();
  }
  
  return _persistentStoreCoordinator;
}


- (void)saveContext {
  NSError *error = nil;
  NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
  
  if (managedObjectContext != nil) {
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
      // Replace this implementation with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
#if DEBUG
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
      
      abort();
    }
  }
}

#pragma mark - Private

- (NSURL *)applicationDocumentsDirectory {
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
