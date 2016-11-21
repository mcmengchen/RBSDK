//
//  RBLoginConfig.h
//  Pods
//
//  Created by william on 16/11/14.
//
//

#import <Foundation/Foundation.h>
//默认的文字大小
#define k_RBLoginKit_DefaultFontSize 17
//默认文字类型
#define k_RBLoginKit_DefaultFontName  @"LTHYSZK"
//不可用颜色色值
#define k_RBLoginKit_Default_UnAbleColor [UIColor colorWithRed:192/255.0 green:192/255.0 blue:193/255.0 alpha:1]
//默认主要色值
#define k_RBLoginKit_Default_MainColor [UIColor colorWithRed:97/255.0 green:212/255.0 blue:255/255.0 alpha:1]
//默认文字颜色
#define k_RBLoginKit_Default_TextColor [UIColor colorWithRed:87/255.0 green:97/255.0 blue:102/255.0 alpha:1]
//默认背景颜色
#define k_RBLoginKit_Default_BackColor [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1]

//设备宽度
#define k_RBLoginKit_ScreenWidth [UIScreen mainScreen].bounds.size.width
//设备高度
#define k_RBLoginKit_ScreenHeight [UIScreen mainScreen].bounds.size.height

//导航的高度
#define k_RBLoginKit_NavHeight 64

//背景颜色
#define k_RBLoginKit_BackColor [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1]
//登录详情信息
#define  k_RBLoginKit_Error_Description [[error userInfo] valueForKey:@"NSLocalizedDescription"]
@interface RBLoginConfig : NSObject

@end
