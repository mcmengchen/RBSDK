//
//  RBLoginKitProtocol.h
//  Pods
//
//  Created by william on 16/11/15.
//
//

#import <Foundation/Foundation.h>
#import "RBUserModel.h"


@protocol RBLoginKitDelegate <NSObject>

@optional
/**
 *  登录结果
 *
 *  @param model 用户模型
 *  @param error 错误
 */
- (void)rb_loginResultWithModel:(RBUserModel *)model Error:(NSError *)error;


/**
 *  注册结果
 *
 *  @param model 用户模型
 *  @param error 错误
 */
- (void)rb_registResultWithModel:(RBUserModel *)model error:(NSError *)error;




/**
 *  重置密码结果
 */
- (void)rb_resetPsdResult:(BOOL)succeed;




@end


#define RB_LoginKit_Manager [RBLoginKitManager sharedManager]

@interface RBLoginKitManager : NSObject

/** 代理 */
@property (nonatomic, assign) id<RBLoginKitDelegate> delegate;


+ (instancetype)sharedManager;



@end
