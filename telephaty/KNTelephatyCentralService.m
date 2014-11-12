//
//  KNTelephatyCentralService.m
//  Telephaty
//
//  Created by Eduardo K. Palenzuela Darias on 16/10/14.
//  Copyright (c) 2014 kiliannet. All rights reserved.
//

#import "KNTelephatyCentralService.h"

#import "MessageDataUtils.h"
#import "KNCoreDataService.h"

@import CoreBluetooth;

static const NSTimeInterval kKNCBScanningTimeout    = 10.0;
static const NSTimeInterval kKNCBConnectingTimeout  = 10.0;
static const NSTimeInterval kKNCBRequestTimeout     = 20.0;

@interface KNTelephatyCentralService() <CBPeripheralDelegate, CBCentralManagerDelegate>

// CoreBluetooth
@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) CBCentralManager *centralManager;

// Specify here which services you want to connect to and characteristics
// you want to read from.
@property (copy, nonatomic, readonly) NSString *serviceName;
@property (copy, nonatomic, readonly) NSArray *serviceUUIDs;  // CBUUIDs
@property (copy, nonatomic, readonly) NSArray *characteristicUUIDs;  // CBUUIDs

// Session information
@property (strong, nonatomic) CBPeripheral *connectedPeripheral;
@property (strong, nonatomic) CBService *connectedService;

// Flags to turn on while waiting for CBCentralManager to get ready.
@property (assign, nonatomic) BOOL subscribeWhenCharacteristicsFound;
@property (assign, nonatomic) BOOL connectWhenReady;

@end

@implementation KNTelephatyCentralService

#pragma mark - Lifecycle

- (instancetype)initWithServiceUUID:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID {
  self = [super init];
  
  if (self) {
    _serviceName = @"Telephaty";
    _serviceUUIDs = @[[CBUUID UUIDWithString:serviceUUID]];
    _characteristicUUIDs = @[[CBUUID UUIDWithString:characteristicUUID]];
    
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
  }
  
  return self;
}

#pragma mark - Private methods

- (void)scanForPeripherals {
  if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
    // Defer scanning until manager comes online.
    self.connectWhenReady = YES;
    return;
  }
  
  NSLog(@"Scanning ...");
  [self startScanningTimeoutMonitor];
  
  // By turning on allow duplicates, it allows us to scan more reliably, but
  // if it finds a peripheral that does not have the services we like or
  // recognize, we'll continually see it again and again in the didDiscover
  // callback.
  NSDictionary *scanningOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey : @YES};
  
  // We could pass in the set of serviceUUIDs when scanning like Apple
  // recommends, but if the application we're scanning for is in the background
  // on the iOS device, then it occassionally will not see any services.
  //
  // So instead, we do the opposite of what Apple recommends and scan
  // with no service UUID restrictions.
  [self.centralManager scanForPeripheralsWithServices:nil options:scanningOptions];
  self.connectWhenReady = NO;
  self.subscribeWhenCharacteristicsFound = NO;
}

- (void)cancelScanForPeripherals {
  [self.centralManager stopScan];
}

#pragma mark - Public methods

// Does all the necessary things to find the device and make a connection.
- (void)connect {
  NSAssert(self.serviceUUIDs.count > 0, @"Need to specify services");
  NSAssert(self.characteristicUUIDs.count > 0, @"Need to specify characteristics UUID");
  
  // Check if there is a Bluetooth LE subsystem turned on.
  if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
    self.connectWhenReady = YES;
    return;
  }
  
  if (self.centralManager) {
    self.connectWhenReady = YES;
    [self scanForPeripherals];
    return;
  }
  
  if (!self.connectedService) {
    self.connectWhenReady = YES;
    [self discoverServices:self.connectedPeripheral];
    return;
  }
}

- (void)disconnect {
  [self cancelScanForPeripherals];
  [self.centralManager cancelPeripheralConnection:self.connectedPeripheral];
  self.connectedPeripheral = nil;
}

// Once connected, subscribes to all the charactersitics that are subscribe-able.
- (void)subscribe {
  if (!self.connectedService) {
    NSLog(@"No connected services for peripheral at all. Unable to subscribe");
    return;
  }
  
  if (self.connectedService.characteristics.count < 1) {
    self.subscribeWhenCharacteristicsFound = YES;
    [self discoverServiceCharacteristics:self.connectedService];
    return;
  }
  
  self.subscribeWhenCharacteristicsFound = NO;
  
  for (CBCharacteristic *characteristic in self.connectedService.characteristics) {
    if (characteristic.properties & CBCharacteristicPropertyNotify) {
      [self.connectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
    }
  }
}

- (void)unsubscribe {
  if (!self.connectedService) return;
  
  for (CBCharacteristic *characteristic in self.connectedService.characteristics) {
    if (characteristic.properties & CBCharacteristicPropertyNotify) {
      [self.connectedPeripheral setNotifyValue:NO forCharacteristic:characteristic];
    }
  }
}

#pragma mark - Private methods

- (void)discoverServices:(CBPeripheral *)peripheral {
  [peripheral setDelegate:self];
  
  // By specifying the actual services we want to connect to, this will
  // work for iOS apps that are in the background.
  //
  // If you specify nil in the list of services and the application is in the
  // background, it may sometimes only discover the Generic Access Profile
  // and the Generic Attribute Profile services.
  //[peripheral discoverServices:nil];
  
  [peripheral discoverServices:self.serviceUUIDs];
}

- (void)discoverServiceCharacteristics:(CBService *)service {
  [self.connectedPeripheral discoverCharacteristics:self.characteristicUUIDs
                                         forService:service];
}

#pragma mark - Connection Timeout

- (void)startScanningTimeoutMonitor {
//  [self cancelScanningTimeoutMonitor];
//  [self performSelector:@selector(scanningDidTimeout)
//             withObject:nil
//             afterDelay:kKNCBScanningTimeout];
}

- (void)cancelScanningTimeoutMonitor {
//  [NSObject cancelPreviousPerformRequestsWithTarget:self
//                                           selector:@selector(scanningDidTimeout)
//                                             object:nil];
}

- (void)scanningDidTimeout {
//  NSLog(@"Scanning did timeout");
////  NSError *error = [[self class] errorWithDescription:@"Unable to find a BTLE device."];
////  [self.delegate centralClient:self connectDidFail:error];
//  
//  [self cancelScanForPeripherals];
}

#pragma mark -

- (void)startConnectionTimeoutMonitor:(CBPeripheral *)peripheral {
  [self cancelConnectionTimeoutMonitor:peripheral];
  [self performSelector:@selector(connectionDidTimeout:)
             withObject:peripheral
             afterDelay:kKNCBConnectingTimeout];
}

- (void)cancelConnectionTimeoutMonitor:(CBPeripheral *)peripheral {
  [NSObject cancelPreviousPerformRequestsWithTarget:self
                                           selector:@selector(connectionDidTimeout:)
                                             object:peripheral];
}

- (void)connectionDidTimeout:(CBPeripheral *)peripheral {
  NSLog(@"connectionDidTimeout: %@", peripheral.identifier);
//  NSError *error = [[self class] errorWithDescription:@"Unable to connect to BTLE device."];
//  [self.delegate centralClient:self connectDidFail:error];
  [self.centralManager cancelPeripheralConnection:peripheral];
}

#pragma mark -

- (void)startRequestTimeout:(CBCharacteristic *)characteristic {
  [self cancelRequestTimeoutMonitor:characteristic];
  [self performSelector:@selector(requestDidTimeout:)
             withObject:characteristic
             afterDelay:kKNCBRequestTimeout];
}

- (void)cancelRequestTimeoutMonitor:(CBCharacteristic *)characteristic {
  [NSObject cancelPreviousPerformRequestsWithTarget:self
                                           selector:@selector(requestDidTimeout:)
                                             object:characteristic];
}

- (void)requestDidTimeout:(CBCharacteristic *)characteristic {
  NSLog(@"requestDidTimeout: %@", characteristic);
//  NSError *error = [[self class] errorWithDescription:@"Unable to request data from BTLE device."];
//  
//  [self.delegate centralClient:self
//      requestForCharacteristic:characteristic
//                       didFail:error];
  
  [self.connectedPeripheral setNotifyValue:NO forCharacteristic:characteristic];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
  switch (central.state) {
    case CBCentralManagerStatePoweredOn:
      if (self.subscribeWhenCharacteristicsFound) {
        if (self.connectedService) {
          [self subscribe];
          return;
        }
      }
      
      if (self.connectWhenReady) {
        [self connect];
        return;
      }
      break;
    default:
      NSLog(@"centralManager did update: %d", central.state);
      break;
  }
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
  
  CBUUID *peripheralUUID = [CBUUID UUIDWithCFUUID:(__bridge CFUUIDRef)(peripheral.identifier)];
  NSLog(@"didDiscoverPeripheral: Peripheral CFUUID: %@", peripheral.identifier);
  NSLog(@"didDiscoverPeripheral: Peripheral CBUUID: %@", peripheralUUID);
  NSLog(@"didDiscoverPeripheral: Name: %@", peripheral.name);
  NSLog(@"didDiscoverPeripheral: Advertisment Data: %@", advertisementData);
  NSLog(@"didDiscoverPeripheral: RSSI: %@", RSSI);
  
  BOOL foundSuitablePeripheral = NO;
  
  // Figure out whether this device has the right service.
  if (!foundSuitablePeripheral) {
    NSArray *serviceUUIDs = [advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey];
    
    for (CBUUID *foundServiceUUIDs in serviceUUIDs) {
      if ([self.serviceUUIDs containsObject:foundServiceUUIDs]) {
        foundSuitablePeripheral = YES;
        break;
      }
    }
  }
  
  // When the iOS app is in background, the advertisments sometimes does not
  // contain the service UUIDs you advertise(!). So we fallback to just
  // check whether the name of the device is the correct one.
  if (!foundSuitablePeripheral) {
    NSString *peripheralName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    foundSuitablePeripheral = [self.serviceName isEqualToString:peripheralName];
  }
  
  // At this point, if we still haven't found one, chances are the
  // iOS app has been killed in the background and the service is not
  // responding any more.
  //
  // There isn't much you can do at this point since connecting the the
  // peripheral won't really do anything if you can't spot the service.
  //
  // TODO: check what alternatives there are, maybe opening up bluetooth-central
  //       as a UIBackgroundModes will work.
  
  
  // If we found something to connect to, start connecting to it.
  // TODO: This does not deal with multiple devices advertising the same service
  //       yet.
  if (foundSuitablePeripheral) {
    [self cancelScanningTimeoutMonitor];
    [self.centralManager stopScan];
    NSLog(@"Connecting ... %@", peripheralUUID);
    [self.centralManager connectPeripheral:peripheral options:nil];
    
    // !!! NOTE: If you don't retain the CBPeripheral during the connection,
    //           this request will silently fail. The below method
    //           will retain peripheral for timeout purposes.
    [self startConnectionTimeoutMonitor:peripheral];
  }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
  NSLog(@"didConnect: %@", peripheral.name);
  [self cancelConnectionTimeoutMonitor:peripheral];
  self.connectedPeripheral = peripheral;
  [self discoverServices:peripheral];
}

- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
  NSLog(@"failedToConnect: %@", peripheral);
  [self cancelConnectionTimeoutMonitor:peripheral];
//  [self.delegate centralClient:self connectDidFail:error];
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
  self.connectedPeripheral = nil;
  self.connectedService = nil;
  NSLog(@"peripheralDidDisconnect: %@", peripheral);
//  [self.delegate centralClientDidDisconnect:self];
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
  if (error) {
//    [self.delegate centralClient:self connectDidFail:error];
    NSLog(@"didDiscoverServices: Error: %@", error);
    // TODO: Need to deal with resetting the state at this point.
    return;
  }
  
  NSLog(@"didDiscoverServices: %@ (Services Count: %ld)",
          peripheral.name, (unsigned long)peripheral.services.count);
  
  for (CBService *service in peripheral.services) {
    NSLog(@"didDiscoverServices: Service: %@", service.UUID);
    
    // Still iterate through all the services for logging purposes, but if
    // we found one, don't bother doing anything more.
    if (self.connectedService) continue;
    
    if ([self.serviceUUIDs containsObject:service.UUID]) {
      self.connectedService = service;
      [self subscribe];
    }
  }
//  [self.delegate centralClientDidConnect:self];
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error {
  if (error) {
//    [self.delegate centralClient:self connectDidFail:error];
    NSLog(@"didDiscoverChar: Error: %@", error);
    return;
  }
  
  // For logging, just print out all the discovered services.
  NSLog(@"didDiscoverChar: Found %ld characteristic(s)", (unsigned long)service.characteristics.count);
  for (CBCharacteristic *characteristic in service.characteristics) {
    NSLog(@"didDiscoverChar:  Characteristic: %@", characteristic.UUID);
  }
  
  // If we did discover characteristics, these will get remembered in the
  // CBService instance, so there's no need to do anything more here
  // apart from remembering the service, in case it changed.
  self.connectedService = service;
  
  if (service.characteristics.count < 1) {
    NSLog(@"didDiscoverChar: did not discover any characterestics for service. aborting.");
    [self disconnect];
    return;
  }
  
  if (self.subscribeWhenCharacteristicsFound) {
    [self subscribe];
  }
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
//  [self cancelRequestTimeoutMonitor:characteristic];
  
  if (error) {
    NSLog(@"didUpdateValueError: %@", error);
//    [self.delegate centralClient:self requestForCharacteristic:characteristic didFail:error];
    return;
  }
  
  
  NSString *messageReceived = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
  
  NSString *myIdentifier = [AppDelegate sharedDelegate].telephatyService.identifier;
  NSDictionary *msgDict = [MessageDataUtils parseMessageData:messageReceived];
  
  if (![myIdentifier isEqualToString:msgDict[@"]transmitter"]]) {
    
    if ([msgDict[@"type"] isEqualToString:@"1"]) {
      MessageData *msgData = [MessageDataUtils addMessageInMOC:[[KNCoreDataService sharedInstance] managedObjectContext] withData:messageReceived];
      
      if (msgData) {
        [self.delegateService telephatyCentralServiceDidReceiveMessage:msgData];
      }
    } else {
      
      if ([msgDict[@"receiver"] isEqualToString:myIdentifier]) {
        MessageData *msgData = [MessageDataUtils addMessageInMOC:[[KNCoreDataService sharedInstance] managedObjectContext] withData:messageReceived];
        
        if (msgData) {
          [self.delegateService telephatyCentralServiceDidReceiveMessage:msgData];
        }
      }
    }
  }

//  NSLog(@"didUpdateValueForChar: Value: %@", characteristic.value);
//  [self.delegate centralClient:self characteristic:characteristic didUpdateValue:characteristic.value];
}

@end