//
//  PDHtmlViewController.h
//  Pudding
//
//  Created by william on 16/2/25.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RBHtmlViewController : UIViewController
/** 导航标题 */
@property (nonatomic, strong) NSString *navTitle;
/** 网页地址 */
@property (nonatomic, strong) NSString * urlString;
/** 是否显示网页本身的title */
@property (nonatomic, assign) BOOL showJSTitle;

@end
