//
//  NTDevice.h
//  nutsdk
//
//  Created by Zhao Hongyi on 15/11/2016.
//  Copyright © 2016 自在科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class NTDevice;
@class NTDeviceAuthController;

typedef NS_ENUM(NSUInteger, NTDeviceState) {
    NTDeviceStateDisconnected = 0,
    NTDeviceStateConnecting,
    NTDeviceStateConnected,
    NTDeviceStateDisconnecting
};

@protocol NTDeviceDelegate <NSObject>

/* It will be called after the device connected to the phone. */
- (void)deviceDidConnect:(NTDevice *)device;

/* It will be called after the device disconnected to the phone. */
- (void)deviceDidDisconnected:(NTDevice *)device;

/* It will be called if the connection attempted failed due to the errro */
- (void)device:(NTDevice *)device didFailedToConnect:(NSError *)error;

/* It will be called after you call readRSSI on a NTDevice object */
- (void)device:(NTDevice *)device didUpdateRSSI:(NSNumber *)RSSI;

/* It will be called after you call readBattery on a NTDevice object */
- (void)device:(NTDevice *)device didUpdateBattery:(NSNumber *) battery;

/* It will be called when you clicked the button on the device.
 numberOfClick Value
 0:long press(press and hold for 2 seconds)
 1:Single Click
 2:Double Click */
- (void)device:(NTDevice *)device didClicked:(NSInteger)numberOfClick;

@end
@interface NTDevice : NSObject

/* The delegate of the NTDevice object */
@property (nonatomic,weak) id <NTDeviceDelegate> delegate;

/* The identifier is a system generated UUID for each device. See CBPeripheral's identifier for more information*/
@property (nonatomic,readonly) NSString *identifier;

/* The local name advertised by the device. */
@property (nonatomic,readonly) NSString *localName;

/* The fireware version read from the device. */
@property (nonatomic,readonly) NSString *firmwareVersion;

/* The hardware version read from the device. */
@property (nonatomic,readonly) NSString *hardwareVersion;

/* Setting this property to YES will trigger auto reconnect after the device disconnected or failed to connect */
@property (nonatomic,assign)   BOOL autoReconnect;

/* The device connection state, see NTDeviceState emun for more information */
@property (nonatomic,assign)   NTDeviceState state;

/* The device's battery level, ranged from 0 to 100 */
@property (nonatomic,readonly) NSNumber *battery;

/* The unique identifier read from the device */
@property (nonatomic,strong,readonly) NSString *deviceID;

@property (nonatomic,strong,readwrite) NTDeviceAuthController *deviceAuthController;

/* Get the system CBPeripheral instance of the current device */
- (CBPeripheral *)blePeripheral;

/* Get the connection status of the current device(by the CBPeripheral instance) */
- (BOOL)isBLEConnected;

/* Used to connect to the device, if the device is already connected, this API does nothing.*/
- (void)connect;

/* Used to disconnect the device, or cancel a pending connection attempt */
- (void)cancelConnection;

/* Used to shutdown to the device, if the device is already disconnected, this API does nothing.*/
- (BOOL)shutdown;

/* If the device is connected, calling this method will send a command to beep the device for the duration passed in. The maximum timeout is 30 seconds*/
- (BOOL)beep:(BOOL)enabled withTimeOutDuration:(NSInteger)timeout;

/* Enabling or disabling the device alarm when the device disconnected from the cell phone */
- (BOOL)setHardwareAlarmEnabled:(BOOL)enabled;

/*Set the Beacon UUID configuration of the device*/
- (BOOL)setBeaconUUID:(NSString *)beaconUUID;

/*Set the Beacon Major and Minor configuration of the device*/
- (BOOL)setBeaconMajor:(NSNumber *)major minor:(NSNumber *)minor;

- (BOOL)switchToDFUMode;

/* Read the RSSI from the device, the result will be send back from delegate method -device:didUpdateRSSI: */
- (void)readRSSI;

/* Read the battery from the device, the result will be send back from delegate method -device:didUpdateBattery: */
- (void)readBattery;

@end
