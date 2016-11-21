//
//  RBAuthApi.m
//  Pods
//
//  Created by baxiang on 16/11/12.
//
//

#import "RBAuthApi.h"
#import "RBNetworkManager.h"
#import "NSString+RBAdd.h"
#import "RBSDKEncrypt.h"
#import "YYModel.h"
#import "NSObject+RBAdd.h"
@implementation RBAuthApi

#pragma mark - 手机号是否已经注册
+ (void)isRegist:(NSString *)phoneNum completionBlock:(void (^)(NSNumber* isRegist,NSError *error)) completionBlock{
     __block  NSError *currError = nil;
    NSDictionary * paraDict = @{@"action":@"user/isregist",@"data":@{@"phonenum":[NSString stringWithFormat:@"%@",phoneNum],@"key":@""}};
    [RBNetworkManager POST:@"/users/regist" auth:NO parameters:paraDict completionBlock:^(id response, NSError *error) {
        NSNumber * isRegist = response?@(1):nil;
        currError = error;
        if ([[error domain] isEqualToString:RBResponseErrorDomain]&&[error code] ==-110) {
             isRegist = @(0);
             currError = nil;
        }
        if ([[error domain] isEqualToString:RBResponseErrorDomain]&&[error code] ==-12) {
            isRegist = nil;
            currError = [NSError errorWithDomain:RBResponseErrorDomain code:-12 userInfo:@{NSLocalizedDescriptionKey:@"请输入正确的手机号码"}];
        }
        if (completionBlock)  completionBlock(isRegist,currError);
    }];
}

#pragma mark - 注册
+ (void)regist:(NSString *)phoneNum password:(NSString *)password code:(NSString *)code nickName:(NSString *)nickName completionBlock:(void (^)(RBUserModel *user,NSError *error)) completionBlock{
    NSString * psd = [password md5HexDigest];
    NSDictionary * paraDict = @{@"action":@"quickregist",@"data":@{@"phonenum":[NSString stringWithFormat:@"%@",phoneNum],@"validcode":[NSString stringWithFormat:@"%@",code],@"pushid": @"",@"tm":[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]],@"passwd":[NSString stringWithFormat:@"%@",psd],@"name":[NSString stringWithFormat:@"%@",nickName]}};
    [RBNetworkManager POST:@"/users/regist" auth:NO parameters:paraDict completionBlock:^(id response, NSError *error) {
        NSDictionary *dataDict =  [[response rb_dictionaryVerify] objectForKey:@"data"];
        NSString *token  = [dataDict stringForKey:@"token" defaultValue:nil];
        NSString *userid  = [dataDict stringForKey:@"userid" defaultValue:nil];
        RBUserModel *model  = [RBUserModel yy_modelWithJSON:response];
        if (token&&userid&&[RBAuthApi saveUser:userid userToken:token]) {
            if (completionBlock) {
                completionBlock(model,nil);
            }
        }else{
            if (completionBlock) {
                completionBlock(nil,error);
            }
        }
        
    }];
}

#pragma mark - 发送验证码
+ (void)sendCode:(NSString *)phoneNum type:(RBSendCodeType )type completionBlock:(void (^)(BOOL isSend,NSError *error)) completionBlock{
    NSString * typeStr = @"";
    switch (type) {
        case RBSendCodeTypeRegister:
            typeStr = @"regist-phone";
            break;
        case RBSendCodeTypeResetPhone:
            typeStr = @"modify-phone";
            break;
        case RBSendCodeTypeResetPsd:
            typeStr = @"password";
            break;
        default:
            break;
    }
    NSDictionary * paraDict = @{@"action":@"newcode",@"data":@{@"phonenum":[NSString stringWithFormat:@"%@",phoneNum],@"usage":typeStr}};
    [RBNetworkManager POST:@"/users/authcode" auth:NO parameters:paraDict completionBlock:^(id response, NSError *error) {
        BOOL success = error? NO:YES;
        if (completionBlock)  completionBlock(success,error);
    }];
}
 #pragma mark - 登陆
+ (void)login:(NSString*)phoneNum passWord:(NSString*)passWord completionBlock:(void (^)(RBUserModel *user,NSError *error)) completionBlock{
    NSString * psd = [passWord md5HexDigest];
    NSDictionary* paraDict = @{@"action":@"login",@"data":@{@"phonenum":[NSString stringWithFormat:@"%@",phoneNum],@"pushid":@"",@"tm":[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]],@"passwd":[NSString stringWithFormat:@"%@",psd],@"wifimac":@""}};
    [RBNetworkManager POST:@"/users/login" auth:NO parameters:paraDict completionBlock:^(id response, NSError *error) {
        NSDictionary *dataDict =  [[response rb_dictionaryVerify] objectForKey:@"data"];
        NSString *token  = [dataDict stringForKey:@"token" defaultValue:nil];
        NSString *userid  = [dataDict stringForKey:@"userid" defaultValue:nil];
        RBUserModel *model  = [RBUserModel yy_modelWithJSON:response];
        if (token&&userid&&[RBAuthApi saveUser:userid userToken:token]) {
            if (completionBlock) {
                completionBlock(model,nil);
            }
        }else{
            if (completionBlock) {
                completionBlock(nil,error);
            }
        }
    }];
}
#pragma mark - 修改手机号
+ (void)updatePhoneNum:(NSString *)phoneNum  code:(NSString *)code password:(NSString *)password completionBlock:(void (^)(BOOL isSuccess,NSError *error)) completionBlock{
    NSDictionary * paraDict = @{@"action":@"resetphone",@"data":@{@"newphone":[NSString stringWithFormat:@"%@",phoneNum],@"validcode":[NSString stringWithFormat:@"%@",code],@"password":[password md5HexDigest],@"validnp":[NSNumber numberWithBool:true]}};
    [RBNetworkManager POST:@"/users/info" auth:YES parameters:paraDict completionBlock:^(id response, NSError *error) {
       BOOL success = error? NO:YES;
        if (completionBlock) completionBlock(success,error);
    }];

}
#pragma mark - 修改密码
+ (void)updatePassword:(NSString *)oldPsd newPsd:(NSString *)newPsd completionBlock:(void (^)(BOOL isSuccess,NSError *error)) completionBlock{
   
    NSString * opsd = [oldPsd md5HexDigest];
    NSString * npsd = [newPsd md5HexDigest];
    NSDictionary * paraDict = @{@"action":@"setpasswd",@"data":@{@"oldpasswd":opsd,@"newpasswd":npsd}};
    [RBNetworkManager POST:@"/users/password" auth:YES parameters:paraDict completionBlock:^(id response, NSError *error) {
        BOOL success = error? NO:YES;;
        if (completionBlock) completionBlock(success,error);
    }];
}

#pragma mark -   重置密码
+ (void)resetPassword:(NSString *)password phoneNum:(NSString*) phoneNum  code :(NSString *)code  completionBlock:(void (^)(BOOL isSuccess,NSError *error)) completionBlock{
    NSDictionary * paraDict = @{@"action":@"resetpasswd",@"data":@{@"phonenum":phoneNum,@"validcode":[NSString stringWithFormat:@"%@",code],@"newpasswd":[password md5HexDigest]}};
    [RBNetworkManager POST:@"/users/password" auth:YES parameters:paraDict completionBlock:^(id response, NSError *error) {
        BOOL success = error? NO:YES;;
        if (completionBlock) completionBlock(success,error);
    }];
}
+(BOOL)saveUser:(NSString*)userid userToken:(NSString*)token{
    [[NSUserDefaults standardUserDefaults] setObject:[RBSDKEncrypt encrypt:userid] forKey:@"userid"];
    [[NSUserDefaults standardUserDefaults] setObject:[RBSDKEncrypt encrypt:token] forKey:@"token"];
    return [[NSUserDefaults standardUserDefaults] synchronize];
    
}



@end
