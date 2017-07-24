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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isBeeping = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.device = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.rightItem.title = [[AppDelegate sharedInstance] isDeviceBound:self.device.identifier] ? @"解绑" : @"绑定";
    
    self.phoneDisconnectSwitch.on = ((NSNumber *)[[AppDelegate sharedInstance] settingForDevice:self.device.identifier key:phoneDisconnectAlertKey]).boolValue;
    self.phoneReconnectSwitch.on = ((NSNumber *)[[AppDelegate sharedInstance] settingForDevice:self.device.identifier key:phoneReconnectAlertKey]).boolValue;
    self.nutAlertSwitch.on = ((NSNumber *)[[AppDelegate sharedInstance] settingForDevice:self.device.identifier key:nutAlertKey]).boolValue;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (![[AppDelegate sharedInstance] isDeviceBound:self.device.identifier]) {
        [self.device setHardwareAlarmEnabled:NO];
        [self.device cancelConnection];
    }
}

- (IBAction)beep:(id)sender
{
    [self.device beep:!isBeeping withTimeOutDuration:15];
    isBeeping = !isBeeping;
}

- (IBAction)rightItemAction:(id)sender
{
    BOOL toBind = ![[AppDelegate sharedInstance] isDeviceBound:self.device.identifier];
    
    if (toBind) {
        [[AppDelegate sharedInstance] bindDevice:self.device.identifier];
        self.rightItem.title = @"解绑";
    } else {
        [[AppDelegate sharedInstance] unbindDevice:self.device.identifier];
        self.rightItem.title = @"绑定";
        [self.device setHardwareAlarmEnabled:NO];
        [self.device cancelConnection];
    }
}

- (IBAction)phoneDisconnectAction:(id)sender
{
    [[AppDelegate sharedInstance] setSettingForDevice:self.device.identifier value:@([sender isOn]) key:phoneDisconnectAlertKey];
}

- (IBAction)phoneReconnectAction:(id)sender
{
    [[AppDelegate sharedInstance] setSettingForDevice:self.device.identifier value:@([sender isOn]) key:phoneReconnectAlertKey];
}

- (IBAction)nutDisconnectAction:(id)sender
{
    [[AppDelegate sharedInstance] setSettingForDevice:self.device.identifier value:@([sender isOn]) key:nutAlertKey];
    [self.device setHardwareAlarmEnabled:[sender isOn]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
