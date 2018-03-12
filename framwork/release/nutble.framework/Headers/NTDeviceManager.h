//
//  NTDeviceManager.h
//  nutsdk
//
//  Created by Zhao Hongyi on 15/11/2016.
//  Copyright © 2016 自在科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class NTDevice;
@protocol NTDeviceManagerDelegate;

@interface NTDeviceManager : NSObject

/* The openID from the SDK provider */
@property (nonatomic,strong) NSString *openID;

@property (nonatomic,weak) id<NTDeviceManagerDelegate> delegate;

/* Returns the singleton instance */
+ (NTDeviceManager *)sharedManager;

/* Initialize the CBCentralManager. However you don't need to call this method unless you've already called destroyCentralManager. */
- (void)initCentralManager;

/* Destroy the CBCentralManager object to clean up BLE objects */
- (void)destroyCentralManager;

/* Start scan nut devices, optionDict accepts NTCentralManagerScanOptionAllowDuplicatesKey
 * as key and NSNumber as a boolean wrapper to disable duplicat filtering 
 */
- (void)startScanWithOptions:(NSDictionary *)optionDict;

/* Stop scanning devices */
- (void)stopScan;

/* Retrieve the NTDevices object with identifiers. The idenfitiers param is an array of CBPeripheral's identifiers*/
- (NSArray *)retrieveDevicesWithIdentifiers:(NSArray  *)identifiers;

@end


@protocol NTDeviceManagerDelegate <NSObject>

/* The method will be called when the CBCentralManagerState changes. */
- (void)deviceManager:(NTDeviceManager *)manager didUpdateState:(CBCentralManagerState)state;

/* The method will be called when a device is discovered */
- (void)deviceManager:(NTDeviceManager *)manager didDiscoveredDevice:(NTDevice *)device RSSI:(NSNumber *)rssi;

@end

/* Option key for startScanWithOptions */
extern NSString *const NTCentralManagerScanOptionAllowDuplicatesKey;

