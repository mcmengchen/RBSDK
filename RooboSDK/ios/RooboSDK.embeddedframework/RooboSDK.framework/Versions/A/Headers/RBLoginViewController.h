//
//  RBLoginViewController.h
//  Pods
//
//  Created by william on 16/11/14.
//
//

#import <UIKit/UIKit.h>
#import "RBUserModel.h"


typedef void (^RBLogin_reusltBack)(RBUserModel * userModel,NSError * err);
typedef void (^RBRegist_reusltBack)(RBUserModel * userModel,NSError * err);
typedef void (^RBForgetPsd_reusltBack)(BOOL isSucceed,NSError * err);

@interface RBLoginViewController : UIViewController

/** 登陆结果回调 */
@property (nonatomic, copy) RBLogin_reusltBack rb_loginBack;
/** 注册结果回调 */
@property (nonatomic, copy) RBRegist_reusltBack rb_registBack;
/** 忘记密码回调 */
@property (nonatomic, copy) RBForgetPsd_reusltBack rb_forgetPsdBack;
+ (instancetype)show;
- (void)dismiss;
@end
