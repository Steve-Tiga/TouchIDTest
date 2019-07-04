//
//  GestureLockViewController.m
//  TouchIDTest
//
//  Created by mac on 2019/5/2.
//  Copyright © 2019年 BSurprise. All rights reserved.
//

#import "GestureLockViewController.h"
#import "GestureLockView.h"
#import "LoginManagement.h"
#import "AppDelegate.h"
#import "HomeViewController.h"
#import "LoginViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "SettingGestureLockVC.h"

typedef void(^AlertDefaultActionBlock)(void);

@interface GestureLockViewController ()<GestureLockViewDelegate>
@property (nonatomic, copy) GestureLockView *gestureLockView;//密碼繪製視圖
@property (nonatomic, assign) NSInteger gestureTime;//手勢解鎖次數
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UIButton *touchIDBtn;

@property (nonatomic, copy) AlertDefaultActionBlock alertDefaultActionBlock;

@property (nonatomic, assign) BOOL isIphoneX;//判斷是否是iphoneX

@end

@implementation GestureLockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view addSubview:self.gestureLockView];
    self.gestureTime = 0;
    [self TouchIDAction:self.touchIDBtn];
    
    //判斷是否有FaceID
    self.isIphoneX = [self isIphoneXClass];
}

- (void)didSelectedGestureLockView:(GestureLockView *)gestureLockView keyNumStr:(NSString *)keyNumStr{
    NSLog(@"%@",keyNumStr);
    self.gestureTime =self.gestureTime +1;
    
    self.tipsLabel.text = [NSString stringWithFormat:@"還可輸入%ld次",5 - self.gestureTime];
    self.tipsLabel.textColor = [UIColor redColor];
    
    if (self.gestureTime >= 5) {
        NSLog(@"超過五次");
        [LoginManagement deleteLoginInfo];
        [self presentViewController:[LoginViewController new] animated:YES completion:nil];
    }
    if (![keyNumStr isEqualToString:[LoginManagement getGestureLockPassword]]) {
        gestureLockView.showErrorStatus = YES;
    }else{
        NSLog(@"驗證成功");
//        [self dismissViewControllerAnimated:YES completion:nil];
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        delegate.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[HomeViewController new]];
    }
}

-(GestureLockView *)gestureLockView{
    if (!_gestureLockView) {
        CGFloat gestureLockViewWidth = [UIScreen mainScreen].bounds.size.width/750*500;
        _gestureLockView = [[GestureLockView alloc]initWithFrame:CGRectMake(0, 0, gestureLockViewWidth, gestureLockViewWidth)];
        _gestureLockView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
        _gestureLockView.delegate = self;
    }
    return _gestureLockView;
}

- (IBAction)forgotToReset:(id)sender {
    [self presentViewController:[SettingGestureLockVC new] animated:YES completion:nil];
}



- (IBAction)TouchIDAction:(id)sender {
    [self getTouchIDResult];
}

-(void)getTouchIDResult{
    //首先判断版本
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) {
        [self alertViewWithTitle: @"系統版本不支持TouchID" withMessage:@"請升級後使用" withMakeSureBtnTitle:@"知道了" withSureBtnAction:nil withCancelBtnTitle:nil];
        return;
    }
    
    LAContext *context = [[LAContext alloc] init];
    context.localizedFallbackTitle = @"手勢解鎖";
    if (@available(iOS 10.0, *)) {
        //        context.localizedCancelTitle = @"22222";
    } else {
        // Fallback on earlier versions
    }
    NSError *error = nil;
    
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:self.isIphoneX? @"驗證已有Face ID" : @"驗證已有手機指紋" reply:^(BOOL success, NSError * _Nullable error) {
            
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    AppDelegate *appdelegat = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    appdelegat.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[HomeViewController new]];
                    //成功後記得保存帳戶密碼到UserInfo
                    NSDictionary *touchInfo = [LoginManagement getTouchIDInfo];
                    [LoginManagement saveLoginInfo:touchInfo];
                    
                });
            }else if(error){
                
                switch (error.code) {
                    case LAErrorAuthenticationFailed:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.isIphoneX ? NSLog(@"FaceID 验证失败") : NSLog(@"TouchID 验证失败");
                        });
                        break;
                    }
                    case LAErrorUserCancel:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.isIphoneX ? NSLog(@"FaceID 被用户手动取消") : NSLog(@"TouchID 被用户手动取消");
                        });
                    }
                        break;
                    case LAErrorUserFallback:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.isIphoneX ? NSLog(@"用户不使用FaceID,选择手动输入密码") : NSLog(@"用户不使用TouchID,选择手动输入密码");
                        });
                    }
                        break;
                    case LAErrorSystemCancel:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.isIphoneX ? NSLog(@"Face ID 被系统取消 (如遇到来电,锁屏,按了Home键等)") : NSLog(@"TouchID 被系统取消 (如遇到来电,锁屏,按了Home键等)");
                        });
                    }
                        break;
                    case LAErrorPasscodeNotSet:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self alertViewWithTitle:self.isIphoneX ?@"Face ID 無法啟動" : @"TouchID 無法啟動" withMessage:@"因為用戶沒有設置密碼" withMakeSureBtnTitle:@"去設置" withSureBtnAction:^{
                                NSURL *url = [NSURL URLWithString:@"App-Prefs:root=PASSCODE"];
                                if ([[UIApplication sharedApplication] canOpenURL:url])
                                {
                                    [[UIApplication sharedApplication] openURL:url];
                                }
                            } withCancelBtnTitle:@"取消"];
                        });
                    }
                        break;
                    case LAErrorTouchIDNotAvailable:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self alertViewWithTitle:self.isIphoneX ? @"Face ID無法啟動" : @"TouchID無法啟動" withMessage:self.isIphoneX ? @"因為設備上沒有FaceID" : @"因為設備上沒有TouchID" withMakeSureBtnTitle:@"知道了" withSureBtnAction:nil withCancelBtnTitle:nil];
                        });
                    }
                        break;
                    case LAErrorTouchIDNotEnrolled:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self alertViewWithTitle:self.isIphoneX ? @"Face ID 無法啟動" : @"TouchID 無法啟動" withMessage:self.isIphoneX ? @"因為用戶沒有設置Face ID" : @"因為用戶沒有設置TouchID" withMakeSureBtnTitle:@"去設置" withSureBtnAction:^{
                                NSURL *url = [NSURL URLWithString:@"App-Prefs:root=PASSCODE"];
                                if ([[UIApplication sharedApplication] canOpenURL:url])
                                {
                                    [[UIApplication sharedApplication] openURL:url];
                                }
                            } withCancelBtnTitle:@"取消"];
                        });
                    }
                        break;
                    case LAErrorTouchIDLockout:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self alertViewWithTitle:self.isIphoneX ? @"Face ID 被鎖定" : @"TouchID 被鎖定" withMessage:self.isIphoneX ? @"連續多次驗證Face ID失敗，系統需要用戶手動輸入密碼" : @"連續多次驗證TouchID失敗，系統需要用戶手動輸入密碼" withMakeSureBtnTitle:@"去輸入" withSureBtnAction:^{
                                NSURL *url = [NSURL URLWithString:@"App-Prefs:root=PASSCODE"];
                                if ([[UIApplication sharedApplication] canOpenURL:url])
                                {
                                    [[UIApplication sharedApplication] openURL:url];
                                }
                            } withCancelBtnTitle:@"取消"];
                        });
                    }
                        break;
                    case LAErrorAppCancel:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"当前软件被挂起并取消了授权 (如App进入了后台等)");
                        });
                    }
                        break;
                    case LAErrorInvalidContext:{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"当前软件被挂起并取消了授权 (LAContext对象无效)");
                        });
                    }
                        break;
                    default:
                        break;
                }
            }
        }];
        
    }else{
        
        [self alertViewWithTitle:self.isIphoneX? @"未開啟系統 Face ID" : @"未開啟系統 Touch ID" withMessage:self.isIphoneX? @"請先在系統設置-Face ID與密碼中開啟" : @"請先在系統設置-Touch ID與密碼中開啟" withMakeSureBtnTitle:@"去開啟" withSureBtnAction:^{
            NSString * urlString = @"App-Prefs:root=Carrier";
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
                    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0) {
                        if (@available(iOS 10.0, *)) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
                        } else {
                            // Fallback on earlier versions
                        }
                    } else {
                        // Fallback on earlier versions
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
                    }
            }
        } withCancelBtnTitle:@"取消"];
    }
}

-(void)alertViewWithTitle:(NSString *)title withMessage:(NSString *)message withMakeSureBtnTitle:(NSString *)sureBtnTitle withSureBtnAction:(AlertDefaultActionBlock)sureAction withCancelBtnTitle:(NSString *)cancelBtnTitle{
    self.alertDefaultActionBlock = sureAction;
    // UIAlertViewController(弹框视图)
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:sureBtnTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self.alertDefaultActionBlock) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.alertDefaultActionBlock();
            });
        }
    }];
    
    if (cancelBtnTitle) {
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelBtnTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:cancel];
    }
    
    [alert addAction:sure];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark 是不是刘海屏手机
- (BOOL)isIphoneXClass
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
