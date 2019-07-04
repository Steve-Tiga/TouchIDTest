//
//  LoginManagement.h
//  TouchIDTest
//
//  Created by mac on 2019/5/2.
//  Copyright © 2019年 BSurprise. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoginManagement : NSObject

//保存登陸信息
+(void)saveLoginInfo:(NSDictionary *)loginInfo;

//獲得登陸信息
+(NSDictionary *)getLoginInfo;

//刪除登陸信息
+(void)deleteLoginInfo;

//保存touchID保留信息
+(void)saveTouchIDInfo:(NSDictionary *)touchIDInfo;

//獲得touchID保留信息
+(NSDictionary *)getTouchIDInfo;

//刪除TouchID保留信息
+(void)deleteTouchIDInfo;

//保存手勢密碼
+(void)saveGestureLockPassword:(NSString *)password;

//獲得GestureLockPassword保留信息
+(NSString *)getGestureLockPassword;

//刪除GestureLockPassword保留信息
+(void)deleteGestureLockPassword;

+(void)saveOpenSafetyTouchIDState:(BOOL)isOpen;

+(BOOL)getOpenSafetyTouchIDState;

#pragma mark 是不是刘海屏手机
+ (BOOL)isIphoneXClass;

@end

NS_ASSUME_NONNULL_END
