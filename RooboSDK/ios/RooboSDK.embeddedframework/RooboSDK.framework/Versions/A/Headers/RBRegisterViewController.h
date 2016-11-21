//
//  PDRegisterViewController.h
//  Pudding
//
//  Created by Zhi Kuiyu on 16/1/28.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//
/**
 *  注册页面
 */
#import <UIKit/UIKit.h>
#import "RBUserModel.h"



typedef void (^RBRegist_resultBack)(RBUserModel * userModel,NSError * err);
@interface RBRegisterViewController : UIViewController

/** 注册成功回调 */
@property (nonatomic, copy) RBRegist_resultBack rb_registBack;

+ (instancetype)show;



@end


