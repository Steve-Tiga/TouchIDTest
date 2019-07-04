//
//  LoginManagement.m
//  TouchIDTest
//
//  Created by mac on 2019/5/2.
//  Copyright © 2019年 BSurprise. All rights reserved.
//

#import "LoginManagement.h"
#import "AppDelegate.h"

#define LoginInfo @"loginInfo"
#define TouchID @"touchID"
#define GesturePassword @"gesturePassword"
#define safetyState @"safetyState" //是否打開app安全驗證

@implementation LoginManagement

+(void)saveLoginInfo:(NSDictionary *)loginInfo{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setObject:loginInfo forKey:LoginInfo];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSDictionary *)getLoginInfo{
    NSDictionary *loginInfo = [[NSUserDefaults standardUserDefaults] objectForKey:LoginInfo];
    return loginInfo;
}

+(void)deleteLoginInfo{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef removeObjectForKey:LoginInfo];
}

+(void)saveTouchIDInfo:(NSDictionary *)touchIDInfo{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setObject:touchIDInfo forKey:TouchID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSDictionary *)getTouchIDInfo{
    NSDictionary *touchInfo = [[NSUserDefaults standardUserDefaults] objectForKey:TouchID];
    return touchInfo;
}

+(void)deleteTouchIDInfo{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef removeObjectForKey:TouchID];
}

+(void)saveGestureLockPassword:(NSString *)password{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setObject:password forKey:GesturePassword];
}

+(NSString *)getGestureLockPassword{
    NSString *gestureLockPassword = [[NSUserDefaults standardUserDefaults] objectForKey:GesturePassword];
    return gestureLockPassword;
}

+(void)deleteGestureLockPassword{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef removeObjectForKey:GesturePassword];
}

+(void)saveOpenSafetyTouchIDState:(BOOL)isOpen{
    //保存打開狀態
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    if (isOpen) {
        [userDef setObject:@"Open" forKey:safetyState];
    }else{
        [userDef removeObjectForKey:safetyState];
    }
}

+(BOOL)getOpenSafetyTouchIDState{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    if ([userDef objectForKey:safetyState]) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark 是不是刘海屏手机
+ (BOOL)isIphoneXClass
{
    BOOL iPhoneX = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {//判断是否是手机
        return iPhoneX;
    }
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            iPhoneX = YES;
        }
    }
    return iPhoneX;
}


@end
