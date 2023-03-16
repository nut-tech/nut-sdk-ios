//
//  AppDelegate.m
//  nutble-demo
//
//  Created by Zhao Hongyi on 22/11/2016.
//  Copyright © 2016 Zizai Tech. All rights reserved.
//

#import "AppDelegate.h"
#import "MBProgressHUD.h"

#import <nutble/nutble.h>


NSString * const phoneDisconnectAlertKey = @"phoneDisconnectAlertKey";
NSString * const nutAlertKey = @"nutAlertKey";
NSString * const phoneReconnectAlertKey = @"phoneReconnectAlertKey";
NSString * const localNameKey = @"localNameKey";

@interface AppDelegate ()

@end

@implementation AppDelegate {
    MBProgressHUD *_hud;
}

+ (instancetype)sharedInstance{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [NTDeviceManager sharedManager].openID = @"45aa345d942588b0d2d295e049157e8b";
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    
                                                    UIUserNotificationTypeBadge |
                                                    
                                                    UIUserNotificationTypeSound);
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                            
                                                                             categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];

    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NTDeviceManager sharedManager] destroyCentralManager];
}

+ (void)runOnMainThread:(void (^)())block{
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            block();
        });
    }
}

#pragma mark Toast
- (void)showBusyWindowWithMessage:(NSString *)message{
    [self showBusyWindowWithMessage:message attachedToView:_window];
}

- (void)showBusyWindowWithMessage:(NSString *)message attachedToView:(UIView *)view{
    [self showBusyWindowWithMessage:message attachedToView:view delay:0.0];
}

- (void)showBusyWindowWithMessage:(NSString *)message attachedToView:(UIView *)view delay:(CGFloat)delay{
    if (view == nil)
        view = _window.rootViewController.view;
    
    if (_hud == nil) {
        _hud = [[MBProgressHUD alloc] initWithView:view];
        _hud.removeFromSuperViewOnHide = YES;
        //		_hud.dimBackground = YES;
        [view addSubview:_hud];
        [_hud showAnimated:YES];
    }
    else {
        _hud.mode = MBProgressHUDModeIndeterminate;
        [_hud showAnimated:NO];
    }
    _hud.graceTime = delay;
    _hud.detailsLabel.text = message;
    _hud.detailsLabel.font = [UIFont boldSystemFontOfSize:16.f];
}

- (void)closeBusyWindow:(BOOL)force{
    [_hud hideAnimated:!force];
    _hud = nil;
}

- (void)markBusyWindowWithSuccess:(BOOL)success message:(NSString *)message{
    UIImage *image = (success ? [UIImage imageNamed:@"check.png"] : [UIImage imageNamed:@"error.png"]);
    if (success && (message == nil))
        message = NSLocalizedString(@"Success!", @"Success status message");
    
    _hud.mode = MBProgressHUDModeCustomView;
    _hud.customView = [[UIImageView alloc] initWithImage:image];
    _hud.detailsLabel.text = message;
    [_hud hideAnimated:YES afterDelay:2.0/*(success ? 0.5 : 1.5)*/];
    _hud = nil;
}

- (void)showToastWithTitle:(NSString *)title detailsTitle:(NSString *)detailsTitle{
    [self showToastWithTitle:title detailsTitle:detailsTitle xOffset:0.f yOffset:0.f];
}

- (void)showToastWithTitle:(NSString *)title detailsTitle:(NSString *)detailsTitle xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset{
    [[self class] runOnMainThread:^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[AppDelegate sharedInstance] window] animated:YES];
        
        hud.mode = MBProgressHUDModeText;
        if (title && [title length] > 0) {
            hud.label.text = title;
        }
        hud.detailsLabel.text = detailsTitle;
        hud.detailsLabel.font = [UIFont boldSystemFontOfSize:16.f];
        hud.margin = 10.f;
        hud.offset = CGPointMake(xOffset, yOffset);
        hud.removeFromSuperViewOnHide = YES;
        
        [hud hideAnimated:YES afterDelay:2];
    }];
}

#pragma mark Data management
- (NSArray *)boundDevices
{
    NSArray *array = [self boundDevicesArray];
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    
    [array enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [mutableArray addObject:[[obj allKeys] firstObject]];
    }];
    
    return [NSArray arrayWithArray:mutableArray];
}

- (NSArray *)boundDevicesArray
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"boundDevices"];
}

- (void)bindDevice:(NSString *)deviceIdentifier
{
    if ([self isDeviceBound:deviceIdentifier]) {
        return;
    }
    NSArray *oldArray = [self boundDevicesArray] ? [self boundDevicesArray] : [NSArray array];
    
    NSArray *devices = [[NTDeviceManager sharedManager] retrieveDevicesWithIdentifiers:@[deviceIdentifier]];
    NTDevice *device = [devices firstObject];
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:oldArray];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@YES forKey:phoneDisconnectAlertKey];
    [dict setObject:@YES forKey:phoneReconnectAlertKey];
    [dict setObject:@YES forKey:nutAlertKey];
    [dict setObject:device.advLocalName forKey:localNameKey];
    
    [mutableArray addObject:@{deviceIdentifier: dict}];
    
    [[NSUserDefaults standardUserDefaults] setObject:mutableArray forKey:@"boundDevices"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)unbindDevice:(NSString *)deviceIdentifier
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:[self boundDevicesArray]];
    
    __block NSUInteger indexToDelete;
    [array enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = [[obj allKeys] firstObject];
        if ([deviceIdentifier isEqualToString:key]) {
            indexToDelete = idx;
            *stop = YES;
        }
    }];
    
    [array removeObjectAtIndex:indexToDelete];
    
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"boundDevices"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isDeviceBound:(NSString *)identifier
{
    NSArray *array = [self boundDevicesArray];
    if (!array || ![array count]) {
        return NO;
    } else {
        __block BOOL isBound = NO;
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *key = [[obj allKeys] firstObject];
            if ([identifier isEqualToString:key]) {
                isBound = YES;
                *stop = YES;
            }
        }];
        return isBound;
    }
}


- (id)settingForDevice:(NSString *)identifier key:(NSString *)key
{
    NSArray *array = [self boundDevicesArray];
    if (!array || ![array count]) {
        return nil;
    } else {
        __block NSDictionary *dict = nil;
        [array enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *identifierKey = [[obj allKeys] firstObject];
            if ([identifier isEqualToString:identifierKey]) {
                dict = [[obj objectForKey:identifierKey] copy];
                *stop = YES;
            }
        }];
        return [dict objectForKey:key];
    }
}

- (void)setSettingForDevice:(NSString *)identifier value:(id)value key:(NSString *)key
{
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:[self boundDevicesArray]];
    if (!mutableArray || ![mutableArray count]) {
        return;
    } else {
        __block NSMutableDictionary *dict = nil;
        [mutableArray enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *identifierKey = [[obj allKeys] firstObject];
            if ([identifierKey isEqualToString:identifier]) {
                dict = [NSMutableDictionary dictionaryWithDictionary:[obj objectForKey:identifierKey]];
                [dict setObject:value forKey:key];
                [mutableArray replaceObjectAtIndex:idx withObject:@{identifier: dict}];
                [[NSUserDefaults standardUserDefaults] setObject:mutableArray forKey:@"boundDevices"];
                [[NSUserDefaults standardUserDefaults] synchronize];

                *stop = YES;
            }
        }];
    }
}
@end
