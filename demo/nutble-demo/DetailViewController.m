//
//  DetailViewController.m
//  nutble-demo
//
//  Created by Zhao Hongyi on 29/11/2016.
//  Copyright © 2016 Zizai Tech. All rights reserved.
//

#import "DetailViewController.h"
#import <nutble/nutble.h>
#import "AppDelegate.h"

@interface DetailViewController () {
    BOOL isBeeping;
}

@end

@implementation DetailViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isBeeping = NO;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    self.device = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.rightItem.title = [[AppDelegate sharedInstance] isDeviceBound:self.device.identifier] ? @"Unpair" : @"Pair";
    
    self.phoneDisconnectSwitch.on = ((NSNumber *)[[AppDelegate sharedInstance] settingForDevice:self.device.identifier key:phoneDisconnectAlertKey]).boolValue;
    self.phoneReconnectSwitch.on = ((NSNumber *)[[AppDelegate sharedInstance] settingForDevice:self.device.identifier key:phoneReconnectAlertKey]).boolValue;
    self.nutAlertSwitch.on = ((NSNumber *)[[AppDelegate sharedInstance] settingForDevice:self.device.identifier key:nutAlertKey]).boolValue;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (![[AppDelegate sharedInstance] isDeviceBound:self.device.identifier]) {
        [self.device setHardwareAlarmEnabled:NO];
        [self.device cancelConnection];
    }
}

- (void)popViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)rightItemAction:(id)sender{
    BOOL toBind = ![[AppDelegate sharedInstance] isDeviceBound:self.device.identifier];
    
    if (toBind) {
        [[AppDelegate sharedInstance] bindDevice:self.device.identifier];
        self.rightItem.title = @"Unpair";
    } else {
        [[AppDelegate sharedInstance] unbindDevice:self.device.identifier];
        self.rightItem.title = @"Pair";
        [self.device setHardwareAlarmEnabled:NO];
        [self.device cancelConnection];
    }
}

- (IBAction)beep:(id)sender{
    [self.device beep:!isBeeping withTimeOutDuration:15];
    isBeeping = !isBeeping;
}

- (IBAction)shutdown:(id)sender{
    [self.device shutdown];
}

- (IBAction)readRSSI:(id)sender{
    [self.device readRSSI];
}

- (IBAction)readBattery:(id)sender{
    [self.device readBattery];
}

- (IBAction)setBeaconUUID:(id)sender {
    [self.device setBeaconUUID:@"10102233-4455-6677-8899-AABBCCDDEEFF"];
//    [self.device setBeaconUUID:@"FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"];
}

- (IBAction)setBeaconMajorMinor:(id)sender {
    [self.device setBeaconMajor:@12 minor:@34];
//    [self.device setBeaconMajor:[NSNumber numberWithInt:INT_MAX] minor:[NSNumber numberWithInt:INT_MAX]];
}

- (IBAction)enterDFUMode:(id)sender {
    if ([self.device switchToDFUMode]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[AppDelegate sharedInstance] showToastWithTitle:@"DFU Process" detailsTitle:@"Click on the DfuTarg device to enter the DFU process"];
            [self popViewController];
        });
    }
}

- (IBAction)phoneDisconnectAction:(id)sender{
    [[AppDelegate sharedInstance] setSettingForDevice:self.device.identifier value:@([sender isOn]) key:phoneDisconnectAlertKey];
}

- (IBAction)nutDisconnectAction:(id)sender{
    [[AppDelegate sharedInstance] setSettingForDevice:self.device.identifier value:@([sender isOn]) key:nutAlertKey];
    [self.device setHardwareAlarmEnabled:[sender isOn]];
}

- (IBAction)phoneReconnectAction:(id)sender{
    [[AppDelegate sharedInstance] setSettingForDevice:self.device.identifier value:@([sender isOn]) key:phoneReconnectAlertKey];
}

@end
