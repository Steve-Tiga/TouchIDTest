//
//  HomeViewController.m
//  TouchIDTest
//
//  Created by mac on 2019/5/2.
//  Copyright © 2019年 BSurprise. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "LoginManagement.h"
#import "GestureLockViewController.h"
#import "SettingGestureLockVC.h"

@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *saveLoginInfo;
@property (weak, nonatomic) IBOutlet UISwitch *isOpenTouchID;
@property (weak, nonatomic) IBOutlet UISwitch *safetyTouchID;//用於安全設置的TouchID
@property (weak, nonatomic) IBOutlet UIButton *deleteGesturePassword;
@property (weak, nonatomic) IBOutlet UIButton *editorGesturePassword;

@property (weak, nonatomic) IBOutlet UILabel *isOpenTouchIDLabel;
@property (nonatomic, assign) BOOL isIphoneX;//判斷是否是iphoneX
@end

@implementation HomeViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([LoginManagement getOpenSafetyTouchIDState] &&[LoginManagement getGestureLockPassword]) {
        self.safetyTouchID.on = YES;
    }else{
        self.safetyTouchID.on = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"TouchIDTest";
    
    self.isIphoneX = [LoginManagement isIphoneXClass];
    self.isOpenTouchIDLabel.text = self.isIphoneX ? @"打開Face ID登錄" : @"打開指紋登錄";
    NSDictionary *TouchIDInfo = [LoginManagement getTouchIDInfo];
    if (TouchIDInfo == nil) {
        //提示是否打開TouchID權限
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:self.isIphoneX ? @"是否開啟 Face ID": @"是否開啟 TouchID" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *open = [UIAlertAction actionWithTitle:@"開啟" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.isOpenTouchID.on = YES;
            NSDictionary *loginInfo = [LoginManagement getLoginInfo];
            [LoginManagement saveTouchIDInfo:loginInfo];
            NSDictionary *touchIDInfo = [LoginManagement getTouchIDInfo];//打開後再一次獲取YTouchID保存的內容
            self.saveLoginInfo.text = self.isIphoneX?[NSString stringWithFormat:@"Face ID保存的信息：\n Username:%@\n Password:%@",touchIDInfo[@"userName"],touchIDInfo[@"password"]]:
            [NSString stringWithFormat:@"TouchID保存的信息：\n Username:%@\n Password:%@",touchIDInfo[@"userName"],touchIDInfo[@"password"]];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:open];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        self.isOpenTouchID.on = YES;
        self.saveLoginInfo.text = self.isIphoneX?[NSString stringWithFormat:@"Face ID保存的信息：\n Username:%@\n Password:%@",TouchIDInfo[@"userName"],TouchIDInfo[@"password"]]:
        [NSString stringWithFormat:@"TouchID保存的信息：\n Username:%@\n Password:%@",TouchIDInfo[@"userName"],TouchIDInfo[@"password"]];
    }
    
    //判斷是否有手勢密碼
    if ([LoginManagement getGestureLockPassword]) {
        self.deleteGesturePassword.hidden = NO;
        self.editorGesturePassword.hidden = NO;
    }else{
        self.deleteGesturePassword.hidden = YES;
        self.editorGesturePassword.hidden = YES;
    }
}

- (IBAction)deleteGesturePasswordAction:(id)sender {
    
    [LoginManagement deleteGestureLockPassword];
    
    if (self.safetyTouchID.on) {
        self.safetyTouchID.on = NO;
    }
    
}

- (IBAction)editorGesturePasswordAction:(id)sender {
    [self.navigationController presentViewController:[SettingGestureLockVC new] animated:YES completion:nil];
}

- (IBAction)openTouchIDAction:(id)sender {
    self.isOpenTouchID.on = !self.isOpenTouchID.on;
    if (self.isOpenTouchID.on) {
        NSDictionary *loginInfo = [LoginManagement getLoginInfo];
        [LoginManagement saveTouchIDInfo:loginInfo];
    }else{
        [LoginManagement deleteTouchIDInfo];
    }
}

- (IBAction)logoutAction:(id)sender {
    [LoginManagement deleteLoginInfo];
    [self.navigationController presentViewController:[LoginViewController new] animated:YES completion:nil];
}

//app安全認證的touchID
- (IBAction)safetyTouchIDAction:(id)sender {
    self.safetyTouchID.on = !self.safetyTouchID.on;

    if (self.safetyTouchID.on) {
        //如果打開是第一次設置就去設置手勢密碼
        NSString *gestureLockPassword = [LoginManagement getGestureLockPassword];
        if (!gestureLockPassword) {
            [self.navigationController presentViewController:[SettingGestureLockVC new] animated:YES completion:nil];
        }
    }
    //保存打開狀態
    [LoginManagement saveOpenSafetyTouchIDState:self.safetyTouchID.on];

}

@end
