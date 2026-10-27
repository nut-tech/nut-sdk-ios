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
    isBeeping = NO;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
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
    [self updateControlsForDeviceFamily];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (![[AppDelegate sharedInstance] isDeviceBound:self.device.identifier]) {
        if (![self.device isFamilyCoexist]) {
            [self.device setHardwareAlarmEnabled:NO];
        }
        [self.device cancelConnection];
    }
}

- (void)updateControlsForDeviceFamily{
    BOOL coexist = [self.device isFamilyCoexist];
    // Beep / disconnect alarm / Nordic DFU do not work on coexist devices.
    self.findDeviceButton.enabled = YES; // still used to open Find My for Find My coexist
    self.nutAlertSwitch.enabled = !coexist;
    if (coexist) {
        self.nutAlertSwitch.on = NO;
    }
}

- (void)popViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showCoexistUnsupportedToast:(NSString *)feature{
    NSString *details = [NSString stringWithFormat:@"%@ is not supported on coexist devices", feature];
    if ([self.device isFamilyFindMyCoexist]) {
        details = [NSString stringWithFormat:@"%@ unavailable. Use Apple Find My for this device.", feature];
    }
    [[AppDelegate sharedInstance] showToastWithTitle:@"Coexist Device" detailsTitle:details];
}

- (BOOL)openFindMyIfPossible{
    NSURL *url = [self.device findMyAppURL];
    if (!url) {
        url = [NSURL URLWithString:@"findmy://items"];
    }
    if (![[UIApplication sharedApplication] canOpenURL:url]) {
        [[AppDelegate sharedInstance] showToastWithTitle:@"Find My"
                                           detailsTitle:@"Unable to open Find My on this phone"];
        return NO;
    }
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    return YES;
}

- (IBAction)rightItemAction:(id)sender{
    BOOL toBind = ![[AppDelegate sharedInstance] isDeviceBound:self.device.identifier];
    
    if (toBind) {
        [[AppDelegate sharedInstance] bindDevice:self.device.identifier];
        self.rightItem.title = @"Unpair";
    } else {
        [[AppDelegate sharedInstance] unbindDevice:self.device.identifier];
        self.rightItem.title = @"Pair";
        if (![self.device isFamilyCoexist]) {
            [self.device setHardwareAlarmEnabled:NO];
        }
        [self.device cancelConnection];
    }
}

- (IBAction)beep:(id)sender{
    if ([self.device isFamilyCoexist]) {
        if ([self.device isFamilyFindMyCoexist]) {
            [self openFindMyIfPossible];
        } else {
            [self showCoexistUnsupportedToast:@"Beep"];
        }
        return;
    }

    BOOL startBeep = !isBeeping;
    if ([self.device beep:startBeep withTimeOutDuration:15]) {
        isBeeping = startBeep;
    } else {
        [[AppDelegate sharedInstance] showToastWithTitle:@"Beep"
                                           detailsTitle:@"Command failed. Is the device connected?"];
    }
}

- (IBAction)shutdown:(id)sender{
    if (![self.device shutdown]) {
        [[AppDelegate sharedInstance] showToastWithTitle:@"Shutdown"
                                           detailsTitle:@"Command failed. Is the device connected?"];
    }
}

- (IBAction)readRSSI:(id)sender{
    [self.device readRSSI];
}

- (IBAction)readBattery:(id)sender{
    [self.device readBattery];
}

- (IBAction)setBeaconUUID:(id)sender {
    [self.device setBeaconUUID:@"10102233-4455-6677-8899-AABBCCDDEEFF"];
}

- (IBAction)setBeaconMajorMinor:(id)sender {
    [self.device setBeaconMajor:@12 minor:@34];
}

- (IBAction)enterDFUMode:(id)sender {
    if ([self.device isFamilyCoexist]) {
        [self showCoexistUnsupportedToast:@"Nordic DFU"];
        return;
    }

    if ([self.device switchToDFUMode]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[AppDelegate sharedInstance] showToastWithTitle:@"DFU Process" detailsTitle:@"Click on the DfuTarg device to enter the DFU process"];
            [self popViewController];
        });
    } else {
        [[AppDelegate sharedInstance] showToastWithTitle:@"DFU"
                                           detailsTitle:@"Failed to enter DFU mode"];
    }
}

- (IBAction)phoneDisconnectAction:(id)sender{
    [[AppDelegate sharedInstance] setSettingForDevice:self.device.identifier value:@([sender isOn]) key:phoneDisconnectAlertKey];
}

- (IBAction)nutDisconnectAction:(id)sender{
    UISwitch *toggle = (UISwitch *)sender;
    if ([self.device isFamilyCoexist]) {
        toggle.on = NO;
        [self showCoexistUnsupportedToast:@"Disconnect alarm"];
        return;
    }

    [[AppDelegate sharedInstance] setSettingForDevice:self.device.identifier value:@(toggle.on) key:nutAlertKey];
    [self.device setHardwareAlarmEnabled:toggle.on];
}

- (IBAction)phoneReconnectAction:(id)sender{
    [[AppDelegate sharedInstance] setSettingForDevice:self.device.identifier value:@([sender isOn]) key:phoneReconnectAlertKey];
}

@end
