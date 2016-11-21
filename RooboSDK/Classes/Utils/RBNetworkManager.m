//
//  RBNetworkManager.m
//  Pods
//
//  Created by baxiang on 16/11/12.
//
//

#import "RBNetworkManager.h"
#import "RBNetwork.h"
#import "NSObject+RBAdd.h"
#import "RBSDKEncrypt.h"
NSString * const RBResponseErrorDomain  = @"RBResponseErrorDomain";
@interface NSDictionary (RBNetworkManager)
- (NSMutableDictionary *)merge:(NSDictionary *)dict;
@end
@implementation NSDictionary (RBNetworkManager)
- (NSMutableDictionary *)merge:(NSDictionary *)dict {
    @try {
        NSMutableDictionary *result = nil;
        if ([self isKindOfClass:[NSMutableDictionary class]]) {
            result = (NSMutableDictionary *)self;
        } else {
            result = [NSMutableDictionary dictionaryWithDictionary:self];
        }
        for (id key in dict) {
            if (result[key] == nil) {
                result[key] = dict[key];
            } else {
                if ([result[key] isKindOfClass:[NSDictionary class]] &&
                    [dict[key] isKindOfClass:[NSDictionary class]]) {
                    result[key] = [result[key] merge:dict[key]];
                } else {
                    result[key] = dict[key];
                }
            }
        }
        return result;
    }
    @catch (NSException *exception) {
        return [self mutableCopy];
    }
}
@end
@interface RBNetworkManager()
@property (nonatomic,strong) NSString *userToken;
@property (nonatomic,strong) NSString *userID;
@end
@implementation RBNetworkManager
static RBNetworkManager *instance = nil;
+ (instancetype)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
        
    });
    return instance;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        [self defaultNetworkConfig];
    }
    return self;
}
+(BOOL)parameterIsError:(id)parameter type:(Class)classType error:(NSError**)error{
    if ([parameter isEmpty]) {
       *error = [NSError errorWithDomain:@"RNParameterError" code:1000 description:@"请求参数为空值"];
       return YES;
    }
    if (![parameter isKindOfClass:classType]) {
        *error = [NSError errorWithDomain:@"RNParameterError" code:1001 description:@"请求参数类型错误"];
        return YES;
    }
    return NO;
}
/**
 网络公共参数配置
 */
-(void)defaultNetworkConfig{
    RBNetworkConfig *config  = [RBNetworkConfig defaultConfig];
    config.baseUrlString = @"https://pds-api.roo.bo";
    config.enableDebug = false;
//    config.baseUrlString = @"http://t1.roobo.net";
    config.defaultRequestSerializer = PDRequestSerializerTypeJSON;
    config.defaultResponseSerializer = PDResponseSerializerTypeJSON;
    NSString * devName = nil;
#ifdef DEBUG
    devName = @"ios-dev" ;
#else
    NSString * Identifier  = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleIdentifierKey];
    if([Identifier isEqualToString:@"com.roo.bo.Pudding1s"]){
        devName = @"ios-enterprise" ;
    }else{
        devName = @"ios" ;
    }
#endif
    NSString * bundleId  = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleIdentifierKey];
    NSString * version  = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    NSString * appversion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    config.baseRequestParams =@{@"data":@{
                                        @"app":@{@"app":@"com.roo.bo.Pudding1s",
                                                 @"aver":@"1.0.14",
                                                 @"ch":@(11000),
                                                 @"cver":@(444),
                                                 @"local":@"zh_CN",
                                                 @"osver":@"0",
                                                 @"via":devName
                                                 }
                                        },
                                @"from":@"ios",
                                
                                };
    
}

-(NSString*)userToken{
//    if (!_userToken) {
       NSString* encryptToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
        
        _userToken = [RBSDKEncrypt decrypt:encryptToken];
//    }
    return _userToken;
}
-(NSString*)userID{
//    if (!_userID) {
        NSString* encryptUserID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
        _userID = [RBSDKEncrypt decrypt:encryptUserID];
//    }
    return _userID;
}



+(void)POST:(NSString*)urlStr auth:(BOOL)isAuth  parameters:(NSDictionary*) parameters completionBlock:(void (^)(id response,NSError *error)) completionBlock{
     [[RBNetworkManager defaultManager] URL:urlStr auth:isAuth parameters:parameters method:PDRequestMethodPost completionBlock:^(__kindof RBNetworkRequest *requestTask, id response, NSError *error) {
         if (completionBlock) {
             completionBlock(response,error);
         }
     }];
}

+(void)UPLOAD:(NSString *)urlStr auth:(BOOL)isAuth parameters:(NSDictionary *)parameters file:(id)file progressBlock:(void(^)(NSProgress *))progressBlock completionBlock:(void (^)(id, NSError *))completionBlock{
    NSDictionary *paraDict = [NSDictionary dictionaryWithDictionary:parameters];
    if (isAuth) {
        NSMutableDictionary *dataPara = [NSMutableDictionary new];
        [dataPara setObject:[RBNetworkManager defaultManager].userToken forKey:@"token"];
        [dataPara setObject:[RBNetworkManager defaultManager].userID forKey:@"myid"];
        paraDict = [@{@"data":dataPara} merge:parameters];
    }
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:paraDict options:NSJSONWritingPrettyPrinted error:nil];
    NSString * json = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    [RBUploadRequest uploadWithURL:urlStr parametes:@{@"json":json} bodyBlock:^(id<AFMultipartFormData>  _Nullable formData) {
        if ([NSStringFromClass([file class]) isEqualToString:@"UIImage"] ) {
            [formData appendPartWithFileData:UIImageJPEGRepresentation(file, 0.5) name:@"file" fileName:@"file.jpg" mimeType:@"image/jpeg"];
        }
    } progress:^(__kindof RBNetworkRequest *task, NSProgress *progress) {
        if (progressBlock) {
            progressBlock(progress);
        }
    } complete:^(__kindof RBNetworkRequest *requestTask, id response, NSError *error) {
        if (completionBlock) {
            completionBlock(response,error);
        }
    }];
}

-(void)URL:(NSString*)urlStr auth:(BOOL)isAuth  parameters:(NSDictionary*) parameters method:(PDRequestMethod)requestMethod completionBlock:(PDRequestCompletionBlock) completionBlock{
    NSDictionary *paraDict = [NSDictionary dictionaryWithDictionary:parameters];
    if (isAuth) {
        NSMutableDictionary *dataPara = [NSMutableDictionary new];
        [dataPara setObject:[RBNetworkManager defaultManager].userToken forKey:@"token"];
        [dataPara setObject:[RBNetworkManager defaultManager].userID forKey:@"myid"];
        paraDict = [@{@"data":dataPara} merge:parameters];
    }
    RBNetworkRequest *request = [RBNetworkRequest new];
    request.requestURL = urlStr;
    request.requestMethod = requestMethod;
    request.requestParameters = paraDict;
    [request startWithCompletionBlock:^(__kindof RBNetworkRequest *requestTask, id response, NSError *error) {
        if (completionBlock) {
            NSString *code  = [response stringForKey:@"result" defaultValue:nil];
            if (code&&[code integerValue]== 0) {
                completionBlock(requestTask,response,nil); return;
            }else if (code&&[code integerValue]!=0){
               NSError *error = [NSError errorWithDomain:RBResponseErrorDomain code:[code integerValue] description:[self errorDescription:[code integerValue]]];
              completionBlock(requestTask,nil,error); return;
            }else if (!code&&error){
              completionBlock(requestTask,nil,error); return;
            }else{
                NSError *error = [NSError errorWithDomain:RBResponseErrorDomain code:0 description:@"数据解析失败"];
                completionBlock(requestTask,nil,error); return;
            }
        }
    }];
}
-(NSString*)errorDescription:(NSInteger)errorCode{
    switch (errorCode) {
        case -102: return @"用户信息过期，请重新登录";
        case -9999: return @"请升级布丁";
        case -321:  return @"布丁没在线";
        case -1 :return @"布丁不在线";
        case -2 :return @"数据库库访问失败";
        case -3 :return @"数据访问失败（数据库连接断开），或者sql语句执行失败等";
        case -4 :return @"数据库更新失败： 可能是没有找到符合条件的行或者更新的值和原先的值相同";
        case -5 :return @"数据库查询没有找到符合条件的行";
        case -9 :return @"服务器发生错误，需要重新调用接口（暂不支持）";
        case -10 :return @"请求串不是合法的json格式字符串";
        case -11 :return @"请求串中缺少参数";
        case -12 :return @"请求参数的格式不对"; //请求参数的格式不对
        case -13 :return @"请求参数中没有找到action字段";
        case -14 :return @"请求参数中没有找到data字段";
        case -22 :return @"服务器不支持当前Api";
        case -30 :return @"验证码错误或过期";
        case -40 :return @"发送短信失败";
        case -50 :return @"布丁不在线";
        case -51 :return @"布丁不在线";
        case -52 :return @"文件打开（or 创建）错误";
        case -80 :return @"网络不通畅";//url(http://api/users/sr:cc63b6ff4c794b91a3fa60838dfba726/name), response()
        case -90 :return @"没有找到指定的升级包";
        case -100 :return @"用户类接口未知错误";
        case -101 :return @"请求参数中没有找到myid或者token，或者这两个字段格式错误";
        case -103 :return @"账号在其他设备上登录（目前不支持）";
        case -110 :return @"电话号码错误（这个号码没有注册，不是号码格式错误）";
        case -111 :return @"密码错误";
        case -112 :return @"myid不存在（目前不支持）";
        case -113 :return @"更新手机号错误（可能是手机号重复等）";
        case -114 :return @"更新推送id失败，用户不存在或者相同";
        case -115 :return @"手机号已经被注册";
        case -116 :return @"没有找到指定的用户id（一般用于接口中的otherid，注意和-112的区别）";
        case -130 :return @"新密码与旧密码相同";
        case -135 :return @"昵称最少2位";
        case -200 :return @"定位器接口未知错误";
        case -201 :return @"devid 不存在（不是格式错误）";
        case -202 :return @"当前用户没有绑定该定位器";
        case -203 :return @"该定位器还没有激活，不能进行操作";
        case -204 :return @"给定位器发送命令失败";
        case -210 :return @"otherid 没有和定位器绑定";
        case -211 :return @"你没有解绑其他人的权限";
        case -212 :return @"今天已经有人邀请过该用户，不需要重复邀请";
        case -213 :return @"记录邀请失败";
        case -214 :return @"指定用户已经和定位器绑定，不用重复绑定";
        case -215 :return @"没有找到符合条件的绑定申请id";
        case -216 :return @"已经同意/拒绝过该绑定申请";
        case -220 :return @"定位失败";
        case -230 :return @"定位器当前正在执行命令，稍后重试";
        case -250 :return @"模块名不存在";
        case -300 :return @"布丁接口未知错误";
        case -301 :return @"修改布丁备注名失败";
        case -302 :return @"名称最少2位";
        case -310 :return @"布丁表中当前连接的服务器地址错误";
        case -311 :return @"向布丁发送命令失败";
        case -312 :return @"没有找到该布丁";
        case -306 :return @"不是有效的布丁";
        case -313 :return @"向布丁发送命令错误，布丁响应超时";
        case -314 :return @"已经绑定该布丁";
        case -315 :return @"没有一个布丁正确配置了wifi（布丁附近没有合适wifi）";
        case -316 :return @"请管理员邀请您绑定该布丁";
        case -319 :return @"该消息已经处理";
        case -320 :return @"绑定太频繁，请稍后重试";
        case -322 :return @"布丁没在线";
        case -323 :return @"布丁响应超时";
        case -337 :return @"已经申请保单";
        case -364 :return @"不是有效的布丁二维码";
        case -370 :return @"个人信息格式错误";
        case -392 :return @"间隔太久了，请重新点播";
        case -401 :return @"布丁上报wifi+lbs信息获取位置失败";
        case -402 :return @"布丁获取天气信息失败";
        case -1001 :return @"网络访问超时";
        case -1009 :return @"请检查网络连接";
        case -5000 :return @"布丁不在线";
        case -80001 :return @"请选择开始结束时间";
        case -10000 :return @"请摘下休眠帖";
        case -10001 :return @"请插入电源后，再控制布丁转动";
        default:
            return [NSString stringWithFormat:@"错误码%zd",errorCode];
    }
}

@end
