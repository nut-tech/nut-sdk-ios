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

@interface NTDevice (RSSI)
@property (nonatomic,readwrite) NSString *RSSI;
@end

@interface TableViewController ()  <NTDeviceManagerDelegate,NTDeviceDelegate>
@property (nonatomic, strong) NSMutableDictionary *devicesByUUID;
@property (nonatomic, strong) NSMutableOrderedSet *unboundDevices;
@property (nonatomic, strong) NSMutableArray *boundDevices;
@property (nonatomic,assign) NSInteger numberOfDevicesToInsert;
@property (nonatomic,strong) NSTimer *refreshTimer;
@property (nonatomic,strong) NTDevice *selectedDevice;
@end

@implementation TableViewController

- (void)viewDidLoad {
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)loadBoundDevices:(BOOL)boot
{
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadBoundDevices:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refreshTimerAction:) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
    
    self.selectedDevice = nil;
}

- (void)refreshTimerAction:(NSTimer *)timer
{
    [self.tableView reloadData];
    
    [self.boundDevices enumerateObjectsUsingBlock:^(NTDevice * _Nonnull device, NSUInteger idx, BOOL * _Nonnull stop) {
        [device readRSSI];
    }];
}

#pragma mark Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
            return @"已绑定";
            break;
        case 1:
            return @"未绑定";
        default:
            return nil;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
            NSString *localName = device.localName ? device.localName : [[AppDelegate sharedInstance] settingForDevice:device.identifier key:localNameKey];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@ ",localName, [NSString stringWithFormat:@" %llX",[device.deviceID longLongValue]], device.RSSI];

            break;
        }
        case 1:
        {
            NTDevice *device = [self.unboundDevices objectAtIndex:indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@ ",device.localName, [NSString stringWithFormat:@" %llX",[device.deviceID longLongValue]], device.RSSI];
            break;
        }
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
            [device connect];
            [[AppDelegate sharedInstance] showBusyWindowWithMessage:@"连接中..."];
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

#pragma mark NTDeviceManagerDelegate

- (void)deviceManager:(NTDeviceManager *)manager didUpdateState:(CBCentralManagerState)state
{
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

- (void)deviceManager:(NTDeviceManager *)manager didDiscoveredDevice:(NTDevice *)device RSSI:(NSNumber *)rssi
{
    if (rssi.integerValue > -50 && rssi.integerValue < 0 && ![self.boundDevices containsObject:device]) {
        [self.unboundDevices insertObject:device atIndex:self.unboundDevices.count];
    }
    device.delegate = self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DetailViewController *vc= (DetailViewController *)[segue destinationViewController];
    vc.device = self.selectedDevice;
}

- (void)deviceDidConnect:(NTDevice *)device
{
    if (((NSNumber *)[[AppDelegate sharedInstance] settingForDevice:device.identifier key:phoneReconnectAlertKey]).boolValue) {
        UILocalNotification *localNotification = [UILocalNotification new];
        localNotification.alertBody = [NSString stringWithFormat:@"%@ 重连", [device.identifier substringWithRange:NSMakeRange(0, 10)]];
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }

    
    if (self.selectedDevice == device) {
        [self performSegueWithIdentifier:@"showDetailSegue" sender:self];
        
        [[AppDelegate sharedInstance] markBusyWindowWithSuccess:YES message:@"连接成功"];
    }
}

- (void)device:(NTDevice *)device didFailedToConnect:(NSError *)error
{
    if (self.selectedDevice == device) {
        [[AppDelegate sharedInstance] markBusyWindowWithSuccess:NO message:@"连接失败"];
    }
}

- (void)device:(NTDevice *)device didClicked:(NSInteger)numberOfClick
{
    switch (numberOfClick) {
        case 0:
        {
            [[AppDelegate sharedInstance] showToastWithTitle:@"按键" detailsTitle:@"长按"];
            break;
        }
        case 1:
        {
            [[AppDelegate sharedInstance] showToastWithTitle:@"按键" detailsTitle:@"单击"];
            break;
        }
        case 2:
        {
            [[AppDelegate sharedInstance] showToastWithTitle:@"按键" detailsTitle:@"双击"];
            break;
        }
        default:
            break;
    }
}

- (void)device:(NTDevice *)device didUpdateBattery:(NSNumber *)batteryLevel
{
    NSLog(@"batter update delegate: %@",batteryLevel);
}

- (void)deviceDidDisconnected:(NTDevice *)device
{
    if (((NSNumber *)[[AppDelegate sharedInstance] settingForDevice:device.identifier key:phoneDisconnectAlertKey]).boolValue) {
        UILocalNotification *localNotification = [UILocalNotification new];
        localNotification.alertBody = [NSString stringWithFormat:@"%@ 断开", [device.identifier substringWithRange:NSMakeRange(0, 10)]];
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
}

- (void)device:(NTDevice *)device didUpdateRSSI:(NSNumber *)RSSI
{
    device.RSSI = [RSSI stringValue];
}

@end
