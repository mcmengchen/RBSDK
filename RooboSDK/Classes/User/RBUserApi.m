//
//  RBUserApi.m
//  Pods
//
//  Created by baxiang on 16/11/12.
//
//

#import "RBUserApi.h"

#import "RBNetworkManager.h"
#import "RBNetwork.h"
#import "YYModel.h"
#import "RBLoginViewController.h"
#import "RBRegisterViewController.h"
#import "RBForgetPsdViewController.h"
#import "RBModifyPsdViewController.h"
#import "RBModifyAcountViewController.h"
@implementation RBUserApi


#pragma mark - action：登陆
+ (void)userLogin:(void (^)(RBUserModel *, NSError *))loginBlock Regist:(void (^)(RBUserModel *, NSError *))registBlock Forget:(void (^)(BOOL , NSError *))forgetBlock{
    RBLoginViewController * vc = [RBLoginViewController show];
    vc.rb_loginBack= loginBlock;
    vc.rb_registBack = registBlock;
    vc.rb_forgetPsdBack = forgetBlock;
}

#pragma mark - action：注册
+(void)userRegist:(void (^)(RBUserModel *, NSError *))completionBlock{
    RBRegisterViewController * vc = [RBRegisterViewController show];
    vc.rb_registBack = completionBlock;
}

#pragma mark - action: 忘记密码
+ (void)userForgetPsd:(nullable void(^)(BOOL isSucceed,NSError * error))completionBlock{
    RBForgetPsdViewController * vc = [RBForgetPsdViewController show];
    vc.rb_forgetPsdBack = completionBlock;
}


#pragma mark - action: 修改账号
+ (void)userModifyAccount:(nullable void(^)(BOOL isSucceed,NSError * error))completionBlock{
    RBModifyAcountViewController * vc = [RBModifyAcountViewController show];
    vc.rb_modifyAccountBack = completionBlock;
}


#pragma mark - action: 修改密码
+ (void)userModifyPsd:(nullable void(^)(BOOL isSucceed,NSError * error))completionBlock{
    RBModifyPsdViewController * vc = [RBModifyPsdViewController show];
    vc.rb_modifyResultBack = completionBlock;
}







#pragma mark - action: 修改用户名称
+ (void)updateUserName:(NSString *)name completionBlock:(void (^)(BOOL  isSuccess,NSError *error)) completionBlock{
    NSDictionary * paraDict = @{@"action":@"username",@"data":@{@"name":name}};
    [RBNetworkManager POST:@"/users/info" auth:YES parameters:paraDict completionBlock:^(id response, NSError *error) {
        BOOL success = error? NO:YES;
        if (completionBlock)  completionBlock(success,error);
    }];
}

+ (void)updateOthersUserID:(NSString *)userID name:(NSString *)name completionBlock:(void (^)(BOOL  isSuccess,NSError *error)) completionBlock{
    NSDictionary * paraDict = @{@"action":@"users/modifyremark",@"data":@{@"otherid":[NSString stringWithFormat:@"%@",userID],@"newname":[NSString stringWithFormat:@"%@",name]}};
    [RBNetworkManager POST:@"/users/info" auth:YES parameters:paraDict completionBlock:^(id response, NSError *error) {
        BOOL success = error? NO:YES;
        if (completionBlock)  completionBlock(success,error);
    }];
}

#pragma mark - action: 上传图片
+ (void)uploadUserImg:(UIImage *)img progressBlock:(void (^)(NSProgress *))progressBlock completionBlock:(void (^)(BOOL, NSError *))completionBlock{
    NSMutableDictionary * resultDict = [[NSMutableDictionary alloc] initWithDictionary:@{@"action":@"uploadimg"}];
    NSMutableDictionary * dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:@"file" forKey:@"file"];
    [dataDict setObject:@"ios" forKey:@"from"];
    [resultDict setObject:dataDict forKey:@"data"];
    [RBNetworkManager UPLOAD:@"/users/upload" auth:true parameters:resultDict file:img progressBlock:^(NSProgress * progress) {
        if (progressBlock) {
            progressBlock(progress);
        }
    } completionBlock:^(id response, NSError *error) {
        NSString * imgUrl = [[response objectForKey:@"data"] objectForKey:@"thumb"];
        [RBUserApi updateUserHeaderImgPath:imgUrl completionBlock:^(BOOL success, NSError *error) {
            BOOL succeed = error? NO:YES;
            if(completionBlock ){
                completionBlock(succeed,error);
            }
        }];
    }];
}

#pragma mark - action: 修改用户头像
+(void)updateUserHeaderImgPath:(NSString *)headerPath completionBlock:(void (^)(BOOL, NSError *))completionBlock{
    NSDictionary * paraDict = @{@"action":@"users/modifyheadimg",@"data":@{@"imgpath":headerPath}};
    [RBNetworkManager POST:@"/users/info" auth:YES parameters:paraDict completionBlock:^(id response, NSError *error) {
        BOOL success = error? NO:YES;
        if (completionBlock){
            completionBlock(success,error);
        }
    }];
}
#pragma mark - action: 退出登录
+ (void)logOut:(void (^)(BOOL isSuccess,NSError *error)) completionBlock{
    [RBNetworkManager POST:@"/users/logout" auth:YES parameters:@{@"action":@"logout"} completionBlock:^(id response, NSError *error) {
        BOOL success = error? NO:YES;
        if (completionBlock){
            completionBlock(success,error);
        }
    }];
}


@end
