//
//  SettingGestureLockVC.m
//  TouchIDTest
//
//  Created by mac on 2019/5/2.
//  Copyright © 2019年 BSurprise. All rights reserved.
//

#import "SettingGestureLockVC.h"
#import "GestureLockView.h"
#import "LoginManagement.h"

@interface SettingGestureLockVC ()<GestureLockViewDelegate>

@property (nonatomic, copy) GestureLockView *gestureLockView;//密碼繪製視圖
@property (nonatomic, copy) NSString *firstPassWord;//保存第一次密碼
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;

@end

@implementation SettingGestureLockVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"設置手勢密碼";
    self.tipsLabel.text = @"請繪製手勢密碼";
    [self.view addSubview:self.gestureLockView];
    
}

- (void)didSelectedGestureLockView:(GestureLockView *)gestureLockView keyNumStr:(NSString *)keyNumStr{
    NSLog(@"%@",keyNumStr);
    
    if (self.firstPassWord) {
        if (![keyNumStr isEqualToString:self.firstPassWord]) {
            gestureLockView.showErrorStatus = YES;
        }else{
            NSLog(@"設置成功");
            [LoginManagement saveGestureLockPassword:keyNumStr];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }else{
        self.firstPassWord = keyNumStr;
        self.tipsLabel.text = @"請再次確認手勢密碼";
    }
}

- (IBAction)dismissSetting:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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




@end
