//
//  PDModifyPhoneNumViewController.h
//  Pudding
//
//  Created by william on 16/2/18.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^RBModifyAccountResult)(BOOL isSucceed,NSError * error);

@interface RBModifyAcountViewController : UIViewController
/** 名称 */
@property (nonatomic, copy) RBModifyAccountResult  rb_modifyAccountBack;
+ (instancetype)show;

@end
