//
//  RBUserApi.h
//  Pods
//
//  Created by baxiang on 16/11/12.
//
//

#import <Foundation/Foundation.h>

@class RBUserModel;
@interface RBUserApi : NSObject


/**
 *  登陆
 *
 *  @param loginBlock  登陆回调
 *  @param registBlock 注册回调
 *  @param forgetBlock 忘记密码回调
 *
 */
+ (void)userLogin:(nullable void(^)(RBUserModel * userModel,NSError * error))loginBlock Regist:(void(^)(RBUserModel * userModel,NSError * error))registBlock Forget:(void(^)(BOOL isSucceed,NSError *error))forgetBlock;

/**
 *  注册
 *
 *  @param completionBlock 注册结果回调
 *
 */
+ (void)userRegist:(nullable void(^)(RBUserModel * userModel,NSError * error))completionBlock;

/**
 *  忘记密码
 *
 *  @param completionBlock 完成回调
 *
 */
+ (void)userForgetPsd:(nullable void(^)(BOOL isSucceed,NSError * error))completionBlock;


/**
 *  修改账号
 *
 *  @param completionBlock 完成回调
 */
+ (void)userModifyAccount:(nullable void(^)(BOOL isSucceed,NSError * error))completionBlock;


/**
 *  修改密码
 *
 *  @param completionBlock 完成回调
 */
+ (void)userModifyPsd:(nullable void(^)(BOOL isSucceed,NSError * error))completionBlock;

/**
 修改其他人的名称 注：管理员才能修改
 
 @param userID 用户的ID
 @param name 用户的名称
 */
+ (void)updateOthersUserID:(NSString *_Nonnull)userID name:(NSString *_Nonnull)name completionBlock:(void (^)(BOOL  isSucceed,NSError *error)) completionBlock;


/**
 更改用户昵称
 @param name 名称
 */
+ (void)updateUserName:(NSString *_Nonnull)name completionBlock:(nullable void (^)(BOOL isSucceed,NSError *error)) completionBlock;

/**
 *  上传用户图片
 *
 *  @param img             图片
 *  @param progressBlock   进度回调
 *  @param completionBlock 完成回调
 */
+ (void)uploadUserImg:(UIImage *_Nonnull)img  progressBlock:(nullable void(^)(NSProgress * progress))progressBlock completionBlock:(nullable void (^)(BOOL isSucceed, NSError * error))completionBlock;

/**
 退出登录
 
 */
+ (void)logOut:(nullable void (^)(BOOL isSucceed,NSError *error)) completionBlock;


@end
