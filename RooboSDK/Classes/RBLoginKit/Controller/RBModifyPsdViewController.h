//
//  PDModifyPsdViewController.h
//  Pudding
//
//  Created by william on 16/2/18.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^RBModifyPsdResult)(BOOL isSucceed,NSError * error);

@interface RBModifyPsdViewController : UIViewController


/** 名称 */
@property (nonatomic, copy) RBModifyPsdResult  rb_modifyResultBack;
+ (instancetype)show;

@end
