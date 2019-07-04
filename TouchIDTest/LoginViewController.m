//
//  LoginViewController.m
//  TouchIDTest
//
//  Created by mac on 2019/5/2.
//  Copyright © 2019年 BSurprise. All rights reserved.
//

#import "LoginViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "HomeViewController.h"
#import "AppDelegate.h"
#import "LoginManagement.h"

typedef void(^AlertDefaultActionBlock)(void);

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UILabel *isOpenTouchID;
@property (weak, nonatomic) IBOutlet UITextField *UserNameTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *passWordTextFiled;
@property (weak, nonatomic) IBOutlet UILabel *saveLoginInfo;
@property (weak, nonatomic) IBOutlet UILabel *touchIDBtnTitleLabel;

@property (nonatomic, copy) AlertDefaultActionBlock alertDefaultActionBlock;

@property (nonatomic, copy) NSDictionary *loginInfo;
@property (nonatomic, copy) NSDictionary *touchIDInfo;

@property (nonatomic, assign) BOOL isIphoneX;//判斷是否是iphoneX
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //判斷是否有FaceID
    self.isIphoneX = [LoginManagement isIphoneXClass];
    self.touchIDBtnTitleLabel.text = self.isIphoneX ?  @"Face ID登錄" : @"指紋登錄";
    
    NSDictionary *touchIDInfo = [LoginManagement getTouchIDInfo];
    //如果有touchIDInfo則代表打開了touchID
    if (touchIDInfo) {
        self.isOpenTouchID.text = self.isIphoneX? @"已打開Face ID，可用FaceID登錄" : @"已打開Touch ID，可用指紋登錄";
        self.saveLoginInfo.text = self.isIphoneX?[NSString stringWithFormat:@"Face ID保存的信息：\n Username:%@\n Password:%@",touchIDInfo[@"userName"],touchIDInfo[@"password"]]:
        [NSString stringWithFormat:@"TouchID保存的信息：\n Username:%@\n Password:%@",touchIDInfo[@"userName"],touchIDInfo[@"password"]];
    }else{
        self.isOpenTouchID.text = self.isIphoneX? @"未打開Face ID，不可Face ID登錄" : @"未打開TouchID，不可用指紋登錄";
    }
    
    //點擊空白隱藏鍵盤
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    singleTap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:singleTap];
    
}

// 点击空白处收键盘
-(void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer {
    [self.view endEditing:YES];
}

- (IBAction)loginAction:(id)sender {
    if (self.UserNameTextFiled.text.length == 0 || self.passWordTextFiled.text.length == 0) {
        return;
    }
    
    NSDictionary *loginInfo = @{@"userName":self.UserNameTextFiled.text,@"password":self.passWordTextFiled.text};
    
    [LoginManagement saveLoginInfo:loginInfo];
    
    if (loginInfo.count > 0) {
        AppDelegate *appdelegat = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appdelegat.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[HomeViewController new]];
    }
}


- (IBAction)touchIDAction:(id)sender {
    if ([LoginManagement getTouchIDInfo]) {
        //是否開啟了指紋登錄
        [self getTouchIDResult];
    }else{
        [self alertViewWithTitle:self.isIphoneX?@"未開啟APP Face ID" : @"未開啟APP TouchID" withMessage:self.isIphoneX? @"請先用帳號密碼登錄後，在app設置-開啟Face ID" : @"請先用帳號密碼登錄後，在app設置-開啟TouchID" withMakeSureBtnTitle:@"知道了" withSureBtnAction:nil withCancelBtnTitle:nil];
    }
    
}

-(void)getTouchIDResult{
    //首先判断版本
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) {
        [self alertViewWithTitle: @"系統版本不支持TouchID" withMessage:@"請升級後使用" withMakeSureBtnTitle:@"知道了" withSureBtnAction:nil withCancelBtnTitle:nil];
        return;
    }
    
    LAContext *context = [[LAContext alloc] init];
    context.localizedFallbackTitle = @"手動輸入";
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
                            [self.UserNameTextFiled becomeFirstResponder];
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
            
            NSURL *url = [NSURL URLWithString:@"App-Prefs:root=PASSCODE"];
            if ([[UIApplication sharedApplication] canOpenURL:url])
            {
                [[UIApplication sharedApplication] openURL:url];
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

@end
