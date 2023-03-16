//
//  ViewController.m
//  nutble-demo
//
//  Created by Zhao Hongyi on 22/11/2016.
//  Copyright © 2016 Zizai Tech. All rights reserved.
//

#import "TableViewController.h"

#import <nutble/nutble.h>
#import "DetailViewController.h"
#import "AppDelegate.h"
#import <iOSDFULibrary/iOSDFULibrary-Swift.h>

@interface NTDevice (RSSI)
@property (nonatomic,readwrite) NSString *RSSI;
@end

@interface TableViewController ()  <NTDeviceManagerDelegate, NTDeviceDelegate, DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate>
@property (nonatomic, strong) NSMutableDictionary *devicesByUUID;
@property (nonatomic, strong) NSMutableOrderedSet *unboundDevices;
@property (nonatomic, strong) NSMutableArray *boundDevices;
@property (nonatomic,assign) NSInteger numberOfDevicesToInsert;
@property (nonatomic,strong) NSTimer *refreshTimer;
@property (nonatomic,strong) NTDevice *selectedDevice;
//Device DFU
@property (nonatomic, assign, readwrite) DFUState deviceDFUState;
@property (nonatomic, retain, readwrite) DFUFirmware *dfuFirmware;
@property (nonatomic, retain, readwrite) DFUServiceInitiator *dfuServiceInitiator;
@property (nonatomic, retain, readwrite) DFUServiceController *dfuServiceController;
@end

@implementation TableViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NTDeviceManager sharedManager] setDelegate:self];

    [[NTDeviceManager sharedManager] startScanWithOptions:@{NTCentralManagerScanOptionAllowDuplicatesKey: @YES}];
    
    self.tableView.rowHeight = 64;
    
    self.devicesByUUID = [NSMutableDictionary dictionary];
    self.unboundDevices = [NSMutableOrderedSet orderedSet];
    self.boundDevices = [NSMutableArray arrayWithCapacity:3];
    
    [self loadBoundDevices:YES];
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadBoundDevices:(BOOL)boot{
    [self.boundDevices removeAllObjects];
    NSArray *boundDevicesID = [[AppDelegate sharedInstance] boundDevices];
    NSArray *boundDevices = [[NTDeviceManager sharedManager] retrieveDevicesWithIdentifiers:boundDevicesID];
    [self.boundDevices addObjectsFromArray:boundDevices];
    [self.boundDevices enumerateObjectsUsingBlock:^(NTDevice*  _Nonnull device, NSUInteger idx, BOOL * _Nonnull stop) {
        if (boot) {
            [device connect];
        }
        if (((NSNumber *)[[AppDelegate sharedInstance] settingForDevice:device.identifier key:nutAlertKey]).boolValue) {
            [device setHardwareAlarmEnabled:YES];
        } else {
            [device setHardwareAlarmEnabled:NO];
        }
        [device setDelegate:self];
        device.autoReconnect = YES;
    }];
    
    [self.unboundDevices removeObjectsInArray:boundDevices];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadBoundDevices:NO];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refreshTimerAction:) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
    self.selectedDevice = nil;
}

- (void)refreshTimerAction:(NSTimer *)timer{
    [self.tableView reloadData];
    
    [self.boundDevices enumerateObjectsUsingBlock:^(NTDevice * _Nonnull device, NSUInteger idx, BOOL * _Nonnull stop) {
        [device readRSSI];
    }];
}

#pragma mark Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return [self.boundDevices count];
        case 1:
            return [self.unboundDevices count];
        default:
            break;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"Paired";
            break;
        case 1:
            return @"Unpair";
        default:
            return nil;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    static NSString *cellID = @"cellID";
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    switch (indexPath.section) {
        case 0:
        {
            NTDevice *device = [self.boundDevices objectAtIndex:indexPath.row];
            NSString *localName = device.advLocalName ? device.advLocalName : [[AppDelegate sharedInstance] settingForDevice:device.identifier key:localNameKey];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@ ",localName, [NSString stringWithFormat:@" %llX",[device.deviceID longLongValue]], device.RSSI];

            break;
        }
        case 1:
        {
            NTDevice *device = [self.unboundDevices objectAtIndex:indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@ ",device.advLocalName, [NSString stringWithFormat:@" %llX",[device.deviceID longLongValue]], device.RSSI];
            break;
        }
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NTDevice *device = nil;
    switch (indexPath.section) {
        case 0:
        {
            device = [self.boundDevices objectAtIndex:indexPath.row];
            break;
        }
        case 1:
        {
            device = [self.unboundDevices objectAtIndex:indexPath.row];
            break;
        }
        default:
            break;
    }
    
    self.selectedDevice = device;

    switch (device.state) {
        case NTDeviceStateConnecting:
        case NTDeviceStateDisconnected:
        {
            if ([device.advLocalName isEqual:@"DfuTarg"]) {
                [self startDeviceDFU:device.blePeripheral];
            } else {
                [device connect];
                [[AppDelegate sharedInstance] showBusyWindowWithMessage:@"Connecting..."];
            }
            break;
        }
        case NTDeviceStateConnected:
        case NTDeviceStateDisconnecting:
        {
            [self performSegueWithIdentifier:@"showDetailSegue" sender:self];
            break;
        }
        default:
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    DetailViewController *vc= (DetailViewController *)[segue destinationViewController];
    vc.device = self.selectedDevice;
}

#pragma mark NTDeviceManagerDelegate

- (void)deviceManager:(NTDeviceManager *)manager didDiscoveredDevice:(NTDevice *)device RSSI:(NSNumber *)rssi{
    if (rssi.integerValue > -60 && rssi.integerValue < 0 && ![self.boundDevices containsObject:device]){
        [self.unboundDevices insertObject:device atIndex:self.unboundDevices.count];
    }
    device.delegate = self;
}

- (void)deviceManager:(NTDeviceManager *)manager didUpdateState:(CBCentralManagerState)state{
    switch (state) {
        case CBCentralManagerStatePoweredOn:
        {
            [[NTDeviceManager sharedManager] startScanWithOptions:@{NTCentralManagerScanOptionAllowDuplicatesKey: @YES}];
            break;
        }
        default:
            break;
    }
}

- (void)deviceDidConnect:(NTDevice *)device{
    if (((NSNumber *)[[AppDelegate sharedInstance] settingForDevice:device.identifier key:phoneReconnectAlertKey]).boolValue) {
        UILocalNotification *localNotification = [UILocalNotification new];
        localNotification.alertBody = [NSString stringWithFormat:@"%@ Reconnect", [device.identifier substringWithRange:NSMakeRange(0, 10)]];
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
    
    if (self.selectedDevice == device) {
        [self performSegueWithIdentifier:@"showDetailSegue" sender:self];
        [[AppDelegate sharedInstance] markBusyWindowWithSuccess:YES message:@"Connect Success"];
    }
}

- (void)device:(NTDevice *)device didFailedToConnect:(NSError *)error{
    if (self.selectedDevice == device) {
        [[AppDelegate sharedInstance] markBusyWindowWithSuccess:NO message:@"Connect Failure"];
    }
}

- (void)device:(NTDevice *)device didClicked:(NSInteger)numberOfClick{
    switch (numberOfClick){
        case 0:
        {
            [[AppDelegate sharedInstance] showToastWithTitle:@"Button Event" detailsTitle:@"Long Click"];
            break;
        }
        case 1:
        {
            [[AppDelegate sharedInstance] showToastWithTitle:@"Button Event" detailsTitle:@"Single Click"];
            break;
        }
        case 2:
        {
            [[AppDelegate sharedInstance] showToastWithTitle:@"Button Event" detailsTitle:@"Double Click"];
            break;
        }
        default:
            break;
    }
}

- (void)device:(NTDevice *)device didUpdateBattery:(NSNumber *)batteryLevel{
    NSNumber *estBattery = [device estimateBatteryLevel];
    NSLog(@"Device Battery update delegate cur:%@%% est:%@%%", batteryLevel, estBattery);
    NSString *batteryLevelText = [NSString stringWithFormat:@"Battery Level %ld%%", (long)batteryLevel.integerValue];
    [[AppDelegate sharedInstance] showToastWithTitle:@"Device State" detailsTitle:batteryLevelText];
}

- (void)deviceDidDisconnected:(NTDevice *)device{
    if (((NSNumber *)[[AppDelegate sharedInstance] settingForDevice:device.identifier key:phoneDisconnectAlertKey]).boolValue) {
        UILocalNotification *localNotification = [UILocalNotification new];
        localNotification.alertBody = [NSString stringWithFormat:@"%@ Disconnected", [device.identifier substringWithRange:NSMakeRange(0, 10)]];
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
}

- (void)device:(NTDevice *)device didUpdateRSSI:(NSNumber *)RSSI{
    NSLog(@"Device Singal RSSI update delegate:%@", RSSI);
    device.RSSI = [RSSI stringValue];
    NSString *RSSIText = [NSString stringWithFormat:@"RSSI Value: %@", RSSI.stringValue];
    [[AppDelegate sharedInstance] showToastWithTitle:@"Device State" detailsTitle:RSSIText];
}

#pragma mark Device DFU handler

- (void)startDeviceDFU:(CBPeripheral *)peripheral{
    if (!peripheral) {
        NSLog(@"startDeviceDFU: dfuServiceController init fail, peripheral is nil.");
        return;
    }
    
    if (!self.dfuFirmware) {
        NSURL *firmwareURL = [[NSBundle mainBundle] URLForResource:@"dfu_fw_114" withExtension:@"zip"];
        if (firmwareURL) {
            self.dfuFirmware = [[DFUFirmware alloc] initWithUrlToZipFile:firmwareURL];
        }
    }
    
    if (!self.dfuServiceInitiator) {
        dispatch_queue_global_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.dfuServiceInitiator = [[DFUServiceInitiator alloc] initWithQueue:queue
                                                                delegateQueue:queue
                                                                progressQueue:queue
                                                                  loggerQueue:queue];
        self.dfuServiceInitiator.logger = self;
        self.dfuServiceInitiator.delegate = self;
        self.dfuServiceInitiator.progressDelegate = self;
    }
    
    if (self.dfuFirmware && self.dfuServiceInitiator) {
        self.dfuServiceInitiator = [self.dfuServiceInitiator withFirmware:self.dfuFirmware];
        self.dfuServiceController = [self.dfuServiceInitiator startWithTarget:peripheral];
    } else {
        NSLog(@"startDeviceDFU: dfuServiceController init fail, params is nil.");
    }
}

- (void)resetDeviceDFUState{
    self.dfuFirmware = nil;
    self.dfuServiceInitiator = nil;
    self.dfuServiceController = nil;
}

- (void)dfuStateDidChangeTo:(enum DFUState)state{
    NSLog(@"dfuStateDidChangeTo dfuState: %ld", (long)state);
    NSString *dfuTips;
    switch (state) {
        case DFUStateConnecting:
            dfuTips = @"Device DFU Connecting";
            break;
        case DFUStateStarting:
            dfuTips = @"Device DFU Starting";
            break;
        case DFUStateEnablingDfuMode:
            break;
        case DFUStateUploading:
            break;
        case DFUStateValidating:
            break;
        case DFUStateDisconnecting:
            break;
        case DFUStateCompleted:
            dfuTips = @"Device DFU Success";
            break;
        case DFUStateAborted:
            [self resetDeviceDFUState];
            break;
        default:
            break;
    }
    self.deviceDFUState = state;
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (dfuTips) {
            [[AppDelegate sharedInstance] showToastWithTitle:@"DFU Process" detailsTitle:dfuTips];
        }
    });
}

- (void)dfuError:(enum DFUError)error didOccurWithMessage:(NSString *)message{
    NSLog(@"DFUServiceDelegate error: %ld, message: %@", (long)error, message);
}

- (void)dfuProgressDidChangeFor:(NSInteger)part outOf:(NSInteger)totalParts to:(NSInteger)progress currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond{
    NSLog(@"DFUProgressDidChange: updating progress: %ld %%", (long)progress);
}

- (void)logWith:(enum LogLevel)level message:(NSString *)message{
    NSLog(@"DFULoggerDelegate log: %@", message);
}

@end
