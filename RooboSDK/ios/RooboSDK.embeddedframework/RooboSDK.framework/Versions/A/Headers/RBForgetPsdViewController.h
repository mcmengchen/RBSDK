//
//  RBForgetPsdViewController.h
//  Pudding
//
//  Created by william on 16/2/3.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//
#import <UIKit/UIKit.h>


typedef void (^RBForgetPsd_resultBack)(BOOL isSucceed,NSError * error);
@interface RBForgetPsdViewController : UIViewController


/** 名称 */
@property (nonatomic, copy) RBForgetPsd_resultBack rb_forgetPsdBack;

+ (instancetype )show;

@end
