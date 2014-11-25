//
//  AppDelegate.m
//  Telephaty
//
//  Created by PEDRO MUÑOZ CABRERA on 12/11/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AppDelegate.h"

#import "KNCoreDataService.h"

#import "PPEncrypt.h"
#import "PPKeyPair.h"

#import "KNConfigurationService.h"
#import "NSData+Base64.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
  
  if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
  }


  [self.telephatyService startEmit];
  [self.telephatyService startWatch];
  

  SecKeyRef publicKey = [self addKey:RSA_PUBLIC_KEY withTag:@"com.qnow.telepahty.publickey2" public:YES];
  SecKeyRef privateKey = [self addKey:RSA_PRIVATE_KEY withTag:@"com.qnow.telepahty.privateKey2" public:NO];
  
  NSString *encrypted = [PPEncrypt encrypt:@"Hello World" withKey:publicKey];
  NSLog(@"Encrypted: %@", encrypted);
  
  NSString *dencrypted = [PPEncrypt decrypt:encrypted withKey:privateKey];
  NSLog(@"Dencrypted: %@", dencrypted);

  return YES;
}


- (NSData *)stripPublicKeyHeader:(NSData *)d_key
{
  // Skip ASN.1 public key header
  if (d_key == nil) return(nil);
  
  unsigned int len = [d_key length];
  if (!len) return(nil);
  
  unsigned char *c_key = (unsigned char *)[d_key bytes];
  unsigned int  idx    = 0;
  
  if (c_key[idx++] != 0x30) return(nil);
  
  if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
  else idx++;
  
  // PKCS #1 rsaEncryption szOID_RSA_RSA
  static unsigned char seqiod[] =
  { 0x30,   0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
    0x01, 0x05, 0x00 };
  if (memcmp(&c_key[idx], seqiod, 15)) return(nil);
  
  idx += 15;
  
  if (c_key[idx++] != 0x03) return(nil);
  
  if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
  else idx++;
  
  if (c_key[idx++] != '\0') return(nil);
  
  // Now make a new NSData from this buffer
  return([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}


- (SecKeyRef)addKey:(NSString *)key withTag:(NSString *)tag public:(BOOL)public{
  NSString *s_key = key;

  if (s_key.length == 0) return(FALSE);
  
  // This will be base64 encoded, decode it.
  NSData *d_key = [NSData base64DataFromString:key];
  if (public) {
    d_key = [self stripPublicKeyHeader:d_key];
  }
  
  if (d_key == nil) return(FALSE);
  
  NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];
  
  // Delete any old lingering key with the same tag
  NSMutableDictionary *dictionaryKey = [[NSMutableDictionary alloc] init];
  [dictionaryKey setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
  [dictionaryKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
  [dictionaryKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
  SecItemDelete((__bridge CFDictionaryRef)dictionaryKey);
  
  CFTypeRef persistKey = nil;
  
  // Add persistent version of the key to system keychain
  [dictionaryKey setObject:d_key forKey:(__bridge id)kSecValueData];
  if (public) {
    [dictionaryKey setObject:(__bridge id) kSecAttrKeyClassPublic forKey:(__bridge id)kSecAttrKeyClass];
  } else {
    [dictionaryKey setObject:(__bridge id) kSecAttrKeyClassPrivate forKey:(__bridge id)kSecAttrKeyClass];
  }

  [dictionaryKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnPersistentRef];
  
  OSStatus secStatus = SecItemAdd((__bridge CFDictionaryRef)dictionaryKey, &persistKey);
  if (persistKey != nil) CFRelease(persistKey);
  
  if ((secStatus != noErr) && (secStatus != errSecDuplicateItem)) {
    return nil;
  }
  
  // Now fetch the SecKeyRef version of the key
  SecKeyRef keyRef = nil;
  
  [dictionaryKey removeObjectForKey:(__bridge id)kSecValueData];
  [dictionaryKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
  [dictionaryKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
  [dictionaryKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
  SecItemCopyMatching((__bridge CFDictionaryRef)dictionaryKey, (CFTypeRef *)&keyRef);
  
  if (keyRef == nil) return nil;
  
  return keyRef;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  
  [[KNCoreDataService sharedInstance] saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[KNCoreDataService sharedInstance] saveContext];
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
