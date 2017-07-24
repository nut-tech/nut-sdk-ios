//
//  DetailViewController.h
//  nutble-demo
//
//  Created by Zhao Hongyi on 29/11/2016.
//  Copyright © 2016 Zizai Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NTDevice;

@interface DetailViewController : UIViewController

@property (nonatomic,strong) NTDevice *device;
@property (nonatomic,weak) IBOutlet UIBarButtonItem *rightItem;
@property (nonatomic,weak) IBOutlet UISwitch *phoneDisconnectSwitch;
@property (nonatomic,weak) IBOutlet UISwitch *phoneReconnectSwitch;
@property (nonatomic,weak) IBOutlet UISwitch *nutAlertSwitch;
@property (nonatomic,weak) IBOutlet UILabel *batteryLevel;

- (IBAction)beep:(id)sender;

@end
