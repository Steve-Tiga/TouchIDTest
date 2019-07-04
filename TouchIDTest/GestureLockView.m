//
//  GestureLockView.m
//  TouchIDTest
//
//  Created by mac on 2019/5/2.
//  Copyright © 2019年 BSurprise. All rights reserved.
//

#import "GestureLockView.h"

@interface UIColor (UdeskSDK)
+ (UIColor *)colorWithHexString:(NSString *)color;
@end


@implementation UIColor (UdeskSDK)

//16进制颜色转换
+ (UIColor *)colorWithHexString:(NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

@end

#define ColorWithHexString(a) [UIColor colorWithHexString:a]
#define GestureLock_ButtonSize CGSizeMake(20,20)//没有选择按钮的大小
#define GestureLock_SelectedButtonSize CGSizeMake(60,60)//选择后按钮的大小
#define GestureLock_SelectedLineColor ColorWithHexString(@"2381F9")//选择时候线的颜色
#define GestureLock_SelectedErrorLineColor ColorWithHexString(@"ff0000") //选择后错误线的颜色
#define GestureLock_NomarlColor ColorWithHexString(@"D5DBE8")

CGFloat const GestureLock_DrawLineWidth  = 2; //画线的宽度
CGFloat const GestureLock_ButtonSpaceH = 30; //横向间隔
CGFloat const GestureLock_ButtonSpaceV = 30; //纵向间隔

NSInteger const GestureLock_EachNum  = 3;
NSInteger const GestureLock_ButtonCount  = 9;

typedef NS_ENUM(NSInteger, GestureLockKeyType) {
    GestureLockKeyNormalType,
    GestureLockKeySelectedType,
    GestureLockKeyErrorType,
};

@interface GestureLockKeyView:UIView

@property (nonatomic, assign) GestureLockKeyType keyType;
@property (nonatomic, strong) UIView *smallView;
@property (nonatomic, strong) UIColor *errorColor;
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *selectedColor;
@end

@implementation GestureLockKeyView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _smallView = [UIView new];
        [self addSubview:_smallView];
        
        
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    ///根据大小来设置圆角
    self.layer.cornerRadius = self.frame.size.height/2;
    
    CGFloat smallView_x = CGRectGetWidth(self.frame)*1/3;
    CGFloat smallView_y = CGRectGetWidth(self.frame)*1/3;
    CGFloat smallView_width = CGRectGetWidth(self.frame)*1/3;
    self.smallView.frame = CGRectMake(smallView_x, smallView_y, smallView_width, smallView_width);
    self.smallView.layer.cornerRadius = self.smallView.frame.size.height/2;
}


- (void)setErrorColor:(UIColor *)errorColor{
    _errorColor = errorColor;
}
- (void)setNormalColor:(UIColor *)normalColor{
    _normalColor = normalColor;
    self.smallView.backgroundColor = _normalColor;
}
- (void)setSelectedColor:(UIColor *)selectedColor{
    _selectedColor = selectedColor;
}

- (void)setKeyType:(GestureLockKeyType)keyType{
    _keyType = keyType;
    if (_keyType == GestureLockKeyNormalType) {
        self.backgroundColor = [UIColor clearColor];
        self.smallView.backgroundColor = self.normalColor;
    }
    if (_keyType == GestureLockKeySelectedType) {
        self.backgroundColor = self.normalColor;
        self.smallView.backgroundColor = self.selectedColor;
    }
    
    if (_keyType == GestureLockKeyErrorType) {
        self.backgroundColor = self.normalColor;
        self.smallView.backgroundColor = self.errorColor;
    }
}

@end

@interface GestureLockView ()
@property (nonatomic, strong) NSMutableArray <GestureLockKeyView *>* keyViewArray;
@property (nonatomic, strong) NSMutableArray <GestureLockKeyView *> *selectedKeyViewArray;
@property (nonatomic, assign) CGPoint movePoint;
@property (nonatomic, strong) CAShapeLayer *drawLayer;

@end

@implementation GestureLockView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.lineWidth = GestureLock_DrawLineWidth;
        self.errorLineColor = GestureLock_SelectedErrorLineColor;
        self.selectedLineColor = GestureLock_SelectedLineColor;
        self.horizontalSpace = GestureLock_ButtonSpaceH;
        self.verticalSpace = GestureLock_ButtonSpaceV;
        self.normalColor = GestureLock_NomarlColor;
        [self setViews];
    }
    return self;
}

- (CAShapeLayer *)drawLayer{
    if (!_drawLayer) {
        _drawLayer = [CAShapeLayer layer];
        _drawLayer.fillColor = [UIColor clearColor].CGColor;
        _drawLayer.lineWidth = self.lineWidth;
        _drawLayer.lineJoin = @"round";
        [self.layer addSublayer:_drawLayer];
    }
    return _drawLayer;
}


- (NSMutableArray *)keyViewArray{
    if (!_keyViewArray) {
        _keyViewArray = @[].mutableCopy;
    }
    return _keyViewArray;
}
- (NSMutableArray *)selectedKeyViewArray{
    if (!_selectedKeyViewArray) {
        _selectedKeyViewArray = @[].mutableCopy;
    }
    return _selectedKeyViewArray;
}

- (void)setHorizontalSpace:(CGFloat)horizontalSpace{
    _horizontalSpace = horizontalSpace;
    [self setNeedsLayout];
}

- (void)setVerticalSpace:(CGFloat)verticalSpace{
    _verticalSpace = verticalSpace;
    [self setNeedsLayout];
}

- (void)setErrorLineColor:(UIColor *)errorLineColor{
    _errorLineColor = errorLineColor;
    for (GestureLockKeyView *view in self.keyViewArray) {
        view.errorColor = errorLineColor;
    }
}
- (void)setSelectedLineColor:(UIColor *)selectedLineColor{
    _selectedLineColor = selectedLineColor;
    for (GestureLockKeyView *view in self.keyViewArray) {
        view.selectedColor = selectedLineColor;
    }
}
- (void)setNormalColor:(UIColor *)normalColor{
    _normalColor = normalColor;
    for (GestureLockKeyView *view in self.keyViewArray) {
        view.normalColor = normalColor;
    }
}
- (void)setShowErrorStatus:(BOOL)showErrorStatus{
    _showErrorStatus = showErrorStatus;
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat keyViewWidth = (CGRectGetWidth(self.frame)- (GestureLock_EachNum-1)*self.horizontalSpace)/GestureLock_EachNum;
    CGFloat keyViewHeight = (CGRectGetHeight(self.frame)- (GestureLock_EachNum-1)*self.verticalSpace)/GestureLock_EachNum;
    for (NSUInteger i=0; i<self.keyViewArray.count; i++) {
        
        NSInteger num = i/GestureLock_EachNum;
        NSInteger remainNum = i%GestureLock_EachNum;
        
        UIView *view = self.keyViewArray[i];
        view.frame = CGRectMake((keyViewWidth+self.horizontalSpace)*remainNum, (keyViewHeight+self.verticalSpace)*num, keyViewWidth, keyViewHeight);
    }
    
}

- (void)setViews{
    self.backgroundColor = [UIColor clearColor];
    for (NSUInteger i = 0; i < GestureLock_ButtonCount; i++) {
        GestureLockKeyView *keyView = [[GestureLockKeyView alloc]init];
        keyView.errorColor = self.errorLineColor;
        keyView.selectedColor = self.selectedLineColor;
        keyView.normalColor = self.normalColor;
        keyView.tag = i+1;
        [self addSubview:keyView];
        [self.keyViewArray  addObject:keyView];
    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (self.selectedKeyViewArray.count>0) {
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        GestureLockKeyView *firstKeyView = [self.selectedKeyViewArray objectAtIndex:0];
        [bezierPath moveToPoint:firstKeyView.center];
        if (self.showErrorStatus) {
            self.drawLayer.strokeColor = self.errorLineColor.CGColor;
            
        }else{
            self.drawLayer.strokeColor = self.selectedLineColor.CGColor;
        }
        for (int i = 0; i < [self.selectedKeyViewArray count]; i++) {
            GestureLockKeyView *KeyView = [self.selectedKeyViewArray objectAtIndex:i];
            if (!self.showErrorStatus) {
                KeyView.keyType = GestureLockKeySelectedType;
            }else{
                KeyView.keyType = GestureLockKeyErrorType;
                
            }
            [bezierPath addLineToPoint:KeyView.center];
        }
        
        if (!CGPointEqualToPoint(self.movePoint, CGPointZero)) {
            [bezierPath addLineToPoint:self.movePoint];
        }
        
        self.drawLayer.path = bezierPath.CGPath;
        
    }else{
        [self.drawLayer removeFromSuperlayer];
        self.drawLayer = nil;
    }
    
    // Drawing code
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint locationPoint = [touch locationInView:self];
    GestureLockKeyView *keyView = [self returnContainKeyViewWithPoint:locationPoint];
    if (keyView) {
        [self.selectedKeyViewArray addObject:keyView];
    }
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint locationPoint = [touch locationInView:self];
    if (CGRectContainsPoint(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), locationPoint)) {
        GestureLockKeyView *keyView = [self returnContainKeyViewWithPoint:locationPoint];
        if (keyView&&![self.selectedKeyViewArray containsObject:keyView]) {
            [self.selectedKeyViewArray addObject:keyView];
        }
        self.movePoint = locationPoint;
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if ([self.delegate respondsToSelector:@selector(didSelectedGestureLockView:keyNumStr:)]) {
        [self.delegate didSelectedGestureLockView:self keyNumStr:[self returnKeyNumStr]];
    }
    if (self.showErrorStatus) {
        [self changeSelectedKeyViewWithKeytype:GestureLockKeyErrorType];
        [self setNeedsDisplay];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.selectedKeyViewArray removeAllObjects];
        self.movePoint = CGPointZero;
        [self setNeedsDisplay];
        [self changeAllKeyViewWithKeytype:GestureLockKeyNormalType];
        self.showErrorStatus = NO;
    });
    
    
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.selectedKeyViewArray removeAllObjects];
    self.movePoint = CGPointZero;
    [self setNeedsDisplay];
    [self changeAllKeyViewWithKeytype:GestureLockKeyNormalType];
}

#pragma mark - 根据坐标找出所在的keyView
- (GestureLockKeyView *)returnContainKeyViewWithPoint:(CGPoint)point{
    GestureLockKeyView *tempView = nil;
    for (GestureLockKeyView *keyView in self.keyViewArray) {
        if (CGRectContainsPoint(keyView.frame, point)) {
            tempView = keyView;
            break;
        }
    }
    return tempView;
}
#pragma mark  - 还原所有keyView的状态
- (void)changeAllKeyViewWithKeytype:(GestureLockKeyType)keyType{
    for (GestureLockKeyView *keyView in self.keyViewArray) {
        if (keyView.keyType != keyType) {
            keyView.keyType = keyType;
        }
    }
}
- (void)changeSelectedKeyViewWithKeytype:(GestureLockKeyType)keyType{
    for (GestureLockKeyView *keyView in self.selectedKeyViewArray) {
        if (keyView.keyType != keyType) {
            keyView.keyType = keyType;
        }
    }
}


- (NSString *)returnKeyNumStr{
    
    NSString *keyNumStr = @"";
    for (int i = 0; i < [self.selectedKeyViewArray count]; i++) {
        
        GestureLockKeyView *KeyView = [self.selectedKeyViewArray objectAtIndex:i];
        keyNumStr = [keyNumStr stringByAppendingString:[NSString stringWithFormat:@"%ld",KeyView.tag]];
    }
    return keyNumStr;
}

@end
