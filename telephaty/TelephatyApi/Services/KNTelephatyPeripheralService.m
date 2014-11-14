//
//  KNTelephatyPeripheralService.m
//  Telephaty
//
//  Created by Eduardo K. Palenzuela Darias on 16/10/14.
//  Copyright (c) 2014 kiliannet. All rights reserved.
//

#import "KNTelephatyPeripheralService.h"

@import CoreBluetooth;

@interface KNTelephatyPeripheralService() <CBPeripheralManagerDelegate>

// CoreBluetooth
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic *characteristic;

@property (assign, nonatomic) BOOL serviceRequiresRegistration;
@property (strong, nonatomic) CBMutableService *service;
@property (copy, nonatomic) NSData *pendingData;

@property (copy, nonatomic, readonly) NSString *serviceName;
@property (copy, nonatomic, readonly) CBUUID *serviceUUID;  // CBUUIDs
@property (copy, nonatomic, readonly) CBUUID *characteristicUUID;  // CBUUIDs

@end

@implementation KNTelephatyPeripheralService

#pragma mark - Lifecycle

- (instancetype)initWithServiceUUID:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID {
  self = [super init];
  
  if (self) {
    _serviceName = @"Telephaty";
    _serviceUUID = [CBUUID UUIDWithString:serviceUUID];
    _characteristicUUID = [CBUUID UUIDWithString:characteristicUUID];
    
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
  }
  
  return self;
}

#pragma mark - Private methods

- (void)enableService {
  // If the service is already registered, we need to re-register it again.
  if (self.service) {
    [self.peripheralManager removeService:self.service];
  }
  
  // Create a BTLE Peripheral Service and set it to be the primary. If it
  // is not set to the primary, it will not be found when the app is in the
  // background.
  self.service = [[CBMutableService alloc] initWithType:self.serviceUUID primary:YES];
  
  // Set up the characteristic in the service. This characteristic is only
  // readable through subscription (CBCharacteristicsPropertyNotify) and has
  // no default value set.
  //
  // There is no need to set the permission on characteristic.
  self.characteristic = [[CBMutableCharacteristic alloc] initWithType:self.characteristicUUID
                                                           properties:CBCharacteristicPropertyNotify
                                                                value:nil
                                                          permissions:CBAttributePermissionsReadable];
  
  // Assign the characteristic.
  self.service.characteristics = [NSArray arrayWithObject:self.characteristic];
  
  // Add the service to the peripheral manager.
  [self.peripheralManager addService:self.service];
}

- (void)disableService {
  if (self.service) {
    [self.peripheralManager removeService:self.service];
    self.service = nil;
  }
  [self stopAdvertising];
}

#pragma mark - Public methods

- (void)sendToSubscribers:(NSData *)data {
  if (self.peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
#if DEBUG
    NSLog(@"sendToSubscribers: peripheral not ready for sending state: %d", self.peripheralManager.state);
#endif    
    return;
  }
  
  BOOL success = [self.peripheralManager updateValue:data forCharacteristic:self.characteristic onSubscribedCentrals:nil];
  
  if (!success) {
#if DEBUG
    NSLog(@"Failed to send data, buffering data for retry once ready.");
#endif
    self.pendingData = data;
    return;
  }
}

- (void)applicationDidEnterBackground {
  // Deliberately continue advertising so that it still remains discoverable.
}

- (void)applicationWillEnterForeground {
#if DEBUG
  NSLog(@"applicationWillEnterForeground.");
#endif
  // I once thought that it would be good to re-advertise and re-enable
  // the services when coming in the foreground, but it does more harm than
  // good. If we do that, then if there was a Central subscribing to a
  // characteristic, that would get reset.
  //
  // So here we deliberately avoid re-enabling or re-advertising the service.
}

// Called when the BTLE advertisments should start. We don't take down
// the advertisments unless the user switches us off.
- (void)startAdvertising {
  if (self.peripheralManager.isAdvertising) {
    [self.peripheralManager stopAdvertising];
  }
  
  NSDictionary *advertisment = @{CBAdvertisementDataServiceUUIDsKey : @[self.serviceUUID],
                                 CBAdvertisementDataLocalNameKey    : self.serviceName};
  [self.peripheralManager startAdvertising:advertisment];
}

- (void)stopAdvertising {
  [self.peripheralManager stopAdvertising];
}

- (BOOL)isAdvertising {
  return [self.peripheralManager isAdvertising];
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManager:(CBPeripheralManager *)peripheral
            didAddService:(CBService *)service
                    error:(NSError *)error {
  // As soon as the service is added, we should start advertising.
  [self startAdvertising];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
  switch (peripheral.state) {
    case CBPeripheralManagerStatePoweredOn:
#if DEBUG
      NSLog(@"peripheralStateChange: Powered On");
#endif
      // As soon as the peripheral/bluetooth is turned on, start initializing
      // the service.
      [self enableService];
      break;
    case CBPeripheralManagerStatePoweredOff: {
#if DEBUG
      NSLog(@"peripheralStateChange: Powered Off");
#endif
      [self disableService];
      self.serviceRequiresRegistration = YES;
      break;
    }
    case CBPeripheralManagerStateResetting: {
#if DEBUG
      NSLog(@"peripheralStateChange: Resetting");
#endif
      self.serviceRequiresRegistration = YES;
      break;
    }
    case CBPeripheralManagerStateUnauthorized: {
#if DEBUG
      NSLog(@"peripheralStateChange: Deauthorized");
#endif
      [self disableService];
      self.serviceRequiresRegistration = YES;
      break;
    }
    case CBPeripheralManagerStateUnsupported: {
#if DEBUG
      NSLog(@"peripheralStateChange: Unsupported");
#endif
      self.serviceRequiresRegistration = YES;
      // TODO: Give user feedback that Bluetooth is not supported.
      break;
    }
    case CBPeripheralManagerStateUnknown:
#if DEBUG
      NSLog(@"peripheralStateChange: Unknown");
#endif
      break;
    default:
      break;
  }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central
didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
#if DEBUG
  NSLog(@"didSubscribe: %@", characteristic.UUID);
  NSLog(@"didSubscribe: - Central: %@", central.identifier);
#endif

}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central
didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
#if DEBUG
  NSLog(@"didUnsubscribe: %@", central.identifier);
#endif

}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral
                                       error:(NSError *)error {
  if (error) {
#if DEBUG
    NSLog(@"didStartAdvertising: Error: %@", error);
#endif
    return;
  }
#if DEBUG
  NSLog(@"didStartAdvertising");
#endif
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
#if DEBUG
  NSLog(@"isReadyToUpdateSubscribers");
#endif
  
  if (self.pendingData) {
    NSData *data = [self.pendingData copy];
    self.pendingData = nil;
    [self sendToSubscribers:data];
  }
}

@end
