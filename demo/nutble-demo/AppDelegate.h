//
//  AppDelegate.h
//  nutble-demo
//
//  Created by Zhao Hongyi on 22/11/2016.
//  Copyright © 2016 Zizai Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (instancetype)sharedInstance;

- (void)showToastWithTitle:(NSString *)title detailsTitle:(NSString *)detailsTitle;

- (void)showBusyWindowWithMessage:(NSString *)message;
- (void)closeBusyWindow:(BOOL)force;
- (void)markBusyWindowWithSuccess:(BOOL)success message:(NSString *)message;

- (BOOL)isDeviceBound:(NSString *)identifier;
- (NSArray *)boundDevices;

- (void)bindDevice:(NSString *)deviceIdentifier;
- (void)unbindDevice:(NSString *)deviceIdentifier;

- (id)settingForDevice:(NSString *)identifier key:(NSString *)key;
- (void)setSettingForDevice:(NSString *)identifier value:(id)value key:(NSString *)key;

@end


extern NSString * const phoneDisconnectAlertKey;
extern NSString * const nutAlertKey;
extern NSString * const phoneReconnectAlertKey;
extern NSString * const localNameKey;
