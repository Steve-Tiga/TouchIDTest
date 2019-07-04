//
//  GestureLockView.h
//  TouchIDTest
//
//  Created by mac on 2019/5/2.
//  Copyright © 2019年 BSurprise. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GestureLockView;

NS_ASSUME_NONNULL_BEGIN

@protocol GestureLockViewDelegate <NSObject>

- (void)didSelectedGestureLockView:(GestureLockView *)gestureLockView keyNumStr:(NSString *)keyNumStr;

@end

@interface GestureLockView : UIView

///垂直间隔
@property (nonatomic, assign) CGFloat verticalSpace;
///水平间隔
@property (nonatomic, assign) CGFloat horizontalSpace;
///画线的宽度
@property (nonatomic, assign) CGFloat lineWidth;
///画线的颜色
@property (nonatomic, strong) UIColor *selectedLineColor;
///错误是画线的颜色
@property (nonatomic, strong) UIColor *errorLineColor;
@property (nonatomic, strong) UIColor *normalColor;

@property (nonatomic, weak) id<GestureLockViewDelegate>delegate;

@property (nonatomic, assign) BOOL showErrorStatus;//展示错误地状态

@end

NS_ASSUME_NONNULL_END
