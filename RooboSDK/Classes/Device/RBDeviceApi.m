//
//  RBDeviceApi.m
//  Pods
//
//  Created by baxiang on 16/11/12.
//
//

#import "RBDeviceApi.h"
#import "RBNetworkManager.h"
#import "YYModel.h"
#import "NSObject+RBAdd.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "RBSDKEncrypt.h"
#import "soundtrans.h"
#import "RBPlayVideo.h"
#import "NSBundle+RBVoice.h"
#import "RBSandboxFile.h"
#import "RBTimerManager.h"
#import "NSObject+RBFilterNull.h"
@implementation RBDeviceApi

/**
 *  获取用户 ID
 *
 */
+ (NSString * )UserId{
    NSString* encryptUserID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    NSString * userId = [RBSDKEncrypt decrypt:encryptUserID];
    return userId;
}


#pragma mark ------------------- 设备配网 ------------------------
#pragma mark - action: 打开声波配网(兼容声音与修改网络)
+ (void)openVoiceConfigNetWithDeviceID:(NSString *_Nonnull) deviceID type:(RBModifyNetType)netType completionBlock:(nullable void (^)(BOOL isSucceed,NSError *error)) completionBlock{
    switch (netType) {
        case RBModifyNetType_ModifyNet:
        {
            //播放打开声波配网文件
            [RBPlayVideo playMusic:[NSBundle openVoiceConfigSourcePath]];
            //调用打开声波配网接口
            NSDictionary * dictPara = @{@"action":@"VoiceServer/startSoundWaveMode",@"data":@{@"mainctl":[NSString stringWithFormat:@"%@",deviceID],@"uid":[RBDeviceApi UserId]}};
            [RBNetworkManager POST:@"/mainctrls/mctlcmd" auth:YES parameters:dictPara completionBlock:^(id response, NSError *error) {
                BOOL success =error?NO:YES;
                if (completionBlock) {
                    completionBlock(success,error);
                }
            }];
        }
            break;
        case RBModifyNetType_BindDevice:
        {
            //播放打开声波配网文件
            [RBPlayVideo playMusic:[NSBundle openVoiceConfigSourcePath]];
            //调用打开声波配网接口
            NSDictionary * dictPara = @{@"action":@"VoiceServer/startSoundWaveMode",@"data":@{@"mainctl":[NSString stringWithFormat:@"%@",deviceID],@"uid":[RBDeviceApi UserId]}};
            [RBNetworkManager POST:@"/mainctrls/mctlcmd" auth:YES parameters:dictPara completionBlock:^(id response, NSError *error) {
                BOOL success =error?NO:YES;
                if (completionBlock) {
                    completionBlock(true,nil);
                }
            }];
        }
            break;
    }
}



#pragma mark - action: 播放声波配网文件
+(void)playVoiceConfigNetFileWithWifiName:(NSString *)wifiName wifiPsd:(NSString *)wifiPsd{
    NSString * urlStr = [[RBSandboxFile GetCachePath] stringByAppendingString:@"wifi.wav"];
    [RBDeviceApi createWifiConfigFileWithWifiName:wifiName wifiPsd:wifiPsd voicePath:urlStr];
    [RBPlayVideo playMusic:urlStr];
}

#pragma mark - action: -> 创建声波配网文件
+ (int)createWifiConfigFileWithWifiName:(NSString *)wifiName wifiPsd:(NSString *)wifiPsd voicePath:(NSString *)voicePath{
    int isScuess = createWifiWarFile(wifiName, wifiPsd, [RBDeviceApi UserId], voicePath);
    return isScuess;
}

#pragma mark - action: 获取配网结果
+(void)getVoiceConfigNetResultWithCompletionBlock:(void (^)(id, NSError *))completionBlock{
    NSDictionary * dictPara = @{@"action":@"mc/getWifiResult",@"data":@{@"from":[RBDeviceApi UserId]}};
    [RBNetworkManager POST:@"/users/custom" auth:YES parameters:dictPara completionBlock:^(id response, NSError *error) {
        if (completionBlock) {
            completionBlock(response,error);
        }
    }];
}


static NSString * k_GetConfigNetResult = @"k_GetConfigNetResult";
#pragma mark - action: 开始获取配网结果
+(void)startGetVoiceConfigNetResultBlock:(void (^)(BOOL, NSDictionary *, NSError *))completionBlock{
    __block int num = 0;
    [[RBTimerManager sharedInstance] scheduledDispatchTimerWithName:k_GetConfigNetResult timeInterval:5 queue:dispatch_get_main_queue() repeats:true actionOption:AbandonPreviousAction action:^{
        if (num<15) {
            num++;
            [RBDeviceApi getVoiceConfigNetResultWithCompletionBlock:^(id response, NSError *error) {
                BOOL success =error?NO:YES;
                NSMutableDictionary * responseDict = [NSMutableDictionary dictionary];
                //有 error
                if (error.code == -5) {
                    NSError * err = [NSError errorWithDomain:RBResponseErrorDomain code:-5 userInfo:@{NSLocalizedDescriptionKey:@"还未获取结果"}];
                    error = err;
                    success = false;
                    [responseDict setObject:@"wait" forKey:@"result"];
                    [responseDict setObject:@"正在获取结果" forKey:@"msg"];
                }
                //没有error
                if (!error) {
                    NSDictionary * dict = [response objectForKey:@"data"];
                    NSString * configResult = [dict objectForKey:@"result"];
                    NSString * ctrlID = [dict objectForKey:@"mainctl"];
                    //没有管理员，绑定失败
                    if ([configResult isEqualToString:@"failure"]) {
                        success = false;
                        [responseDict setObject:@"failure" forKey:@"result"];
                        [responseDict setObject:@"绑定失败" forKey:@"msg"];
                    }
                    if([ctrlID length] > 0 && [configResult isEqualToString:@"success"]){
                        if ([[dict objectForKey:@"isBinded"]intValue] == 1) {
                            //绑定成功
                            success = true;
                            [responseDict setObject:@"success" forKey:@"result"];
                            [responseDict setObject:@"绑定成功" forKey:@"msg"];
                            [[RBTimerManager sharedInstance] cancelTimerWithName:k_GetConfigNetResult];
                        } else {
                            //已有管理员
                            success = false;
                            //获取管理员
                            NSString * manager = [dict objectForKey:@"bindtel"];
                            [responseDict setObject:manager forKey:@"bindtel"];
                            [responseDict setObject:@"failure" forKey:@"result"];
                            [responseDict setObject:@"已有管理员，绑定失败" forKey:@"msg"];
                        }
                    }
                }
                if (completionBlock) {
                    completionBlock(success,responseDict,error);
                }
            }];
        }else{
            NSMutableDictionary * responseDict = [NSMutableDictionary dictionary];
            [responseDict setObject:@"failure" forKey:@"result"];
            [responseDict setObject:@"获取结果超时，绑定失败" forKey:@"msg"];
            if (completionBlock) {
                completionBlock(false,responseDict,nil);
            }
            [[RBTimerManager sharedInstance] cancelTimerWithName:k_GetConfigNetResult];
        }
    }];
}

static NSString * k_GetModifyConfigNetResult = @"k_GetModifyConfigNetResult";
#pragma mark - action: 获取修改网络结果
+(void)startGetModifyNetResultBlock:(void (^)(BOOL, NSDictionary *, NSError *))completionBlock{
    __block int num = 0;
    [[RBTimerManager sharedInstance] scheduledDispatchTimerWithName:k_GetModifyConfigNetResult timeInterval:5 queue:dispatch_get_main_queue() repeats:true actionOption:AbandonPreviousAction action:^{
        if (num<15) {
            num++;
            [RBDeviceApi getVoiceConfigNetResultWithCompletionBlock:^(id response, NSError *error) {
                BOOL success =error?NO:YES;
                NSMutableDictionary * responseDict = [NSMutableDictionary dictionary];
                //有 error
                if (error.code == -5) {
                    NSError * err = [NSError errorWithDomain:RBResponseErrorDomain code:-5 userInfo:@{NSLocalizedDescriptionKey:@"还未获取结果"}];
                    error = err;
                    success = false;
                    [responseDict setObject:@"wait" forKey:@"result"];
                    [responseDict setObject:@"正在获取结果" forKey:@"msg"];
                }
                //没有 error
                if (!error) {
                    NSDictionary * dict = [response objectForKey:@"data"];
                    NSString * configResult = [dict objectForKey:@"result"];
                    NSString * ctrlID = [dict objectForKey:@"mainctl"];
                    if ([configResult isEqualToString:@"failure"]) {
                        success = false;
                        [responseDict setObject:@"failure" forKey:@"result"];
                        [responseDict setObject:@"修改失败" forKey:@"msg"];
                    }
                    
                    if ([ctrlID mStrLength] > 0 && [configResult isEqualToString:@"success"]) {
                        success = true;
                        [responseDict setObject:@"success" forKey:@"result"];
                        [responseDict setObject:@"修改成功" forKey:@"msg"];
                        [[RBTimerManager sharedInstance] cancelTimerWithName:k_GetModifyConfigNetResult];
                    }
                }
                if (completionBlock) {
                    completionBlock(success,responseDict,error);
                }
            }];
        }else{
            NSMutableDictionary * responseDict = [NSMutableDictionary dictionary];
            [responseDict setObject:@"failure" forKey:@"result"];
            [responseDict setObject:@"获取结果超时" forKey:@"msg"];
            if (completionBlock) {
                completionBlock(false,responseDict,nil);
            }
            [[RBTimerManager sharedInstance] cancelTimerWithName:k_GetModifyConfigNetResult];
        }
    }];

    
    
    
    
}



#pragma mark ------------------- 设备权限 ------------------------

+ (void)changeManager:(NSString *)deviceID userID:(NSString *)userID completionBlock:(void (^)(BOOL isSuccess, NSError *))completionBlock{
    NSDictionary * dictPara = @{@"action":@"transmgr",@"data":@{@"mainctl":[NSString stringWithFormat:@"%@",deviceID],@"otherid":[NSString stringWithFormat:@"%@",userID]}};
    [RBNetworkManager POST:@"/mainctrls/mcbind" auth:YES parameters:dictPara completionBlock:^(id response, NSError *error) {
        BOOL success =error?NO:YES;
        if (completionBlock) {
            completionBlock(success,error);
        }
    }];
}

+ (void)deleteOwnDevice:(NSString *) deviceID completionBlock:(void (^)(BOOL isSuccess,NSError *error)) completionBlock{
    NSDictionary * dictPara = @{@"action":@"delmctl",@"data":@{@"mainctl":[NSString stringWithFormat:@"%@",deviceID]}};
    [RBNetworkManager POST:@"/mainctrls/mcbind" auth:YES parameters:dictPara completionBlock:^(id response, NSError *error) {
        BOOL success =error?NO:YES;
        if (completionBlock) {
            completionBlock(success,error);
        }
    }];
}

+ (void)addUser:(NSString *)userPhone deviceID:(NSString*)deviceID completionBlock:(void (^)(id response,NSError *error)) completionBlock{
    NSDictionary * dictPara = @{@"action":@"invite",@"data":@{@"phonenum":userPhone,@"mainctl":[NSString stringWithFormat:@"%@",deviceID]}};
    [RBNetworkManager POST:@"/mainctrls/mcbind" auth:YES parameters:dictPara completionBlock:^(id response, NSError *error) {
        BOOL success =error?NO:YES;
        if (completionBlock) {
            completionBlock(response,error);
        }
    }];
}

+ (void)deleteUser:(NSString *)userid deviceID:(NSString*)deviceID  completionBlock:(void (^)(id response,NSError *error)) completionBlock{
    NSDictionary * dictPara = @{@"action":@"deluser",@"data":@{@"userid":userid,@"mainctl":[NSString stringWithFormat:@"%@",deviceID]}};
    [RBNetworkManager POST:@"/mainctrls/mcbind" auth:YES parameters:dictPara completionBlock:^(id response, NSError *error) {
        BOOL success =error?NO:YES;
        if (completionBlock) {
            completionBlock(response,error);
        }
    }];
}

+ (void)fetchAllDevices:(void(^)(NSArray <RBDeviceModel*>*device,NSError *error))completionBlock{
    NSDictionary * dictPara = @{@"action":@"getmclist"};
    [RBNetworkManager POST:@"/users/getbindmcs" auth:YES parameters:dictPara completionBlock:^(id response, NSError *error) {
        NSDictionary *responseDict = [response rb_dictionaryVerify];
        NSArray *deveices   =  [NSArray yy_modelArrayWithClass:[RBDeviceModel class] json: [[responseDict objectForKey:@"data"] objectForKey:@"mcids"]];
        if (completionBlock) {
            completionBlock(deveices,error);
        }
    }];
}


+ (void)updateDeviceName:(NSString*)deviceID name:(NSString *)newName completionBlock:(void (^)(BOOL isSuccess,NSError *error)) completionBlock{
    NSDictionary * dict = @{@"action":@"mctlname",@"data":@{@"mainctl":[NSString stringWithFormat:@"%@",deviceID],@"newname":newName}};
    [RBNetworkManager POST:@"/mainctrls/mctlinfo" auth:YES parameters:dict completionBlock:^(id response, NSError *error) {
        BOOL success =error?NO:YES;
        if (completionBlock) {
            completionBlock(success,error);
        }
    }];
}


+ (void)switchSafetyState:(NSString*)deviceID isOn:(BOOL)isOn completionBlock:(void (^)(BOOL isSuccess,NSError *error)) completionBlock{
    NSDictionary * dict = @{@"action":@"autodefense",@"data":@{@"mainctl":[NSString stringWithFormat:@"%@",deviceID],@"enable":[NSNumber numberWithBool:isOn]}};
    [RBNetworkManager POST:@"/mainctrls/defense" auth:YES parameters:dict completionBlock:^(id response, NSError *error) {
        BOOL success =error?NO:YES;
        if (completionBlock) {
            completionBlock(success,error);
        }
    }];
}

+ (void)updateSafetyTime:(NSString*)deviceID startTime:(NSString * )startTime endTime:(NSString *)endTime  completionBlock:(void (^)(BOOL isSuccess,NSError *error)) completionBlock{
    
    NSDictionary * dictPara = @{@"action":@"securitytime",@"data":@{@"start":[NSString stringWithFormat:@"%@",startTime],@"end":[NSString stringWithFormat:@"%@",endTime],@"mainctl":[NSString stringWithFormat:@"%@",deviceID]}};
    [RBNetworkManager POST:@"/mainctrls/defense" auth:YES  parameters:dictPara completionBlock:^(id response, NSError *error) {
        BOOL success = error?NO:YES;
        if (completionBlock) {
            completionBlock(success,error);
        }
    }];

}

#pragma mark - action: 获取设备硬件信息
+ (void)fetchHardwareInfo:(NSString*)deviceID completion:(void(^)(RBHardware*device,NSError *error))completionBlock{
    NSDictionary * dictPara = @{@"action":@"puddinfo",@"data":@{@"mainctl":[NSString stringWithFormat:@"%@",deviceID]}};
    [RBNetworkManager POST:@"/mainctrls/mctlgetter" auth:YES  parameters:dictPara completionBlock:^(id response, NSError *error) {
        RBHardware *hardware   = [RBHardware yy_modelWithJSON:response];
        if (completionBlock) {
            completionBlock(hardware,error);
        }
    }];
}

#pragma mark - action: 获取设备详情
+ (void)fetchDeviceDetail:(NSString *) deviceID completionBlock:(void (^)(RBDevicesDetail *detail,NSError *error)) completionBlock{
    NSDictionary * dictPara = @{@"action":@"detail",@"data":@{@"mainctl":[NSString stringWithFormat:@"%@",deviceID]}};
    [RBNetworkManager POST:@"/mainctrls/mctlgetter" auth:YES parameters:dictPara completionBlock:^(id response, NSError *error) {
          RBDevicesDetail *deviceMoel = [RBDevicesDetail yy_modelWithJSON:response];
        if (completionBlock) {
            completionBlock(deviceMoel,error);
        }
    }];
}
#pragma mark ------------------- 设备控制 ------------------------
#pragma mark - action: 重启设备
+ (void)restart:(NSString *) deviceID  completionBlock:(void (^)(BOOL isSuccess,NSError *error)) completionBlock{
     NSDictionary * paraDict = @{@"action":@"DeviceManager/Shutdown",@"data":@{@"restart":@"true",@"timer":@"0",@"slient":@"false",@"mainctl":[NSString stringWithFormat:@"%@",deviceID]}};
    [RBNetworkManager POST:@"/mainctrls/mctlcmd" auth:YES parameters:paraDict completionBlock:^(id response, NSError *error) {
        BOOL success =error?NO:YES;
        if (completionBlock) {
            completionBlock(success,error);
        }
    }];
}
+(void)updateNightMode:(NSString *) deviceID nightSetting:(RBNightSetting)settingType switchState:(BOOL)switchState startTime:(NSString * )startTime endTime:(NSString *)endTime completionBlock:(void (^)(BOOL isSuccess,NSError *error)) completionBlock{
    NSMutableDictionary *paraDict = [NSMutableDictionary dictionary];
    [paraDict setObject:@"nightmode/set" forKey:@"action"];
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:[NSString stringWithFormat:@"%@",deviceID] forKey:@"mainctl"];
    [dataDict setObject:@[@{@"start":startTime,@"end":endTime}] forKey:@"timerang"];
    if (settingType == RBNightSettingSwitch) {
        [dataDict setObject:@"toggle" forKey:@"type"];
    }else{
        [dataDict setObject:@"settime" forKey:@"type"];
    }
    [paraDict setObject:dataDict forKey:@"data"];
    [dataDict setObject:[NSString stringWithFormat:@"%d",switchState] forKey:@"state"];
    [RBNetworkManager POST:@"/users/nightmode" auth:YES parameters:paraDict completionBlock:^(id response, NSError *error) {
        BOOL success =error?NO:YES;
        if (completionBlock) {
            completionBlock(success,error);
        }
    }];
}

+ (void)rotateDevice:(NSString *)deviceID angle:(float)angle completionBlock:(void (^)(BOOL isSuccess,NSError *error)) completionBlock{
    CGFloat currAngle = (angle/180)*36;
    NSDictionary * paraDict = @{@"action":@"DeviceManage/motorRotate",@"data":@{@"angle":[NSNumber numberWithFloat:currAngle],@"mainctl":deviceID}};
    [RBNetworkManager POST:@"/mainctrls/mctlcmd" auth:YES parameters:paraDict completionBlock:^(id response, NSError *error) {
        BOOL success =error?NO:YES;
        if (completionBlock) {
            completionBlock(success,error);
        }
    }];
}
+ (void)sendEmoji:(NSString *)deviceID emojiType:(RBEmojiType) emojiType completionBlock:(void (^)(BOOL isSuccess,NSError *error)) completionBlock{
    NSDictionary * paraDict = @{@"action":@"LedControl/showExpression",@"data":@{@"type":[NSNumber numberWithInt:emojiType],@"mainctl":[NSString stringWithFormat:@"%@",deviceID]}};
    [RBNetworkManager POST:@"/mainctrls/mctlcmd" auth:YES parameters:paraDict completionBlock:^(id response, NSError *error) {
        BOOL success =error?NO:YES;
        if (completionBlock) {
            completionBlock(success,error);
        }
    }];
}
+ (void)sendTTS:(NSString *)deviceID content:(NSString *)text completionBlock:(void (^)(BOOL isSuccess,NSError *error)) completionBlock{
    NSDictionary * paraDict = @{@"action":@"VoiceServer/textToSpeech",@"data":@{@"text":[NSString stringWithFormat:@"%@",text],@"mainctl":[NSString stringWithFormat:@"%@",deviceID]}};
    [RBNetworkManager POST:@"/mainctrls/mctlcmd" auth:YES parameters:paraDict completionBlock:^(id response, NSError *error) {
        BOOL success =error?NO:YES;
        if (completionBlock) {
            completionBlock(success,error);
        }
    }];
}



#pragma mark ------------------- 设备设置 ------------------------
+ (void)updateVolume:(NSString *) deviceID voice:(float)voiceValue completionBlock:(void (^)(BOOL isSuccess,NSError *error)) completionBlock{
    float currVolume = voiceValue;
    if (currVolume<0) {
        currVolume = 0;
    }else if (currVolume>100){
        currVolume = 100;
    }
    NSDictionary * paraDict = @{@"action":@"VoiceServer/changeMasterVolume",@"data":@{@"volume":[NSNumber numberWithFloat:voiceValue],@"mainctl":[NSString stringWithFormat:@"%@",deviceID]}};
   
    [RBNetworkManager POST:@"/mainctrls/mctlcmd" auth:YES parameters:paraDict completionBlock:^(id response, NSError *error) {
        BOOL success =error?NO:YES;
        if (completionBlock) {
            completionBlock(success,error);
        }
    }];

}
+ (void)updateSound:(NSString *) deviceID  soundName:(NSString*)soundName completionBlock:(void (^)(BOOL isSuccess,NSError *error)) completionBlock {
    NSDictionary * paraDict = @{@"action":@"mctlcmd/timbre",@"data":@{@"mainctl":[NSString stringWithFormat:@"%@",deviceID],@"role":[NSString stringWithFormat:@"%@",soundName]}};
    [RBNetworkManager POST:@"/users/mctlcmd" auth:YES parameters:paraDict completionBlock:^(id response, NSError *error) {
        BOOL success =error?NO:YES;
        if (completionBlock) {
            completionBlock(success,error);
        }
    }];
}

+ (void)switchVideoConnetVoice:(NSString *) deviceID isOn:(BOOL) isOn completionBlock:(void (^)(BOOL isSuccess,NSError *error)) completionBlock{
       NSDictionary * paraDict = @{@"action":@"VideoMaster/userEnterRemind",@"data":@{@"status":[NSNumber numberWithBool:isOn],@"mainctl":[NSString stringWithFormat:@"%@",deviceID]}};
       [RBNetworkManager POST:@"/mainctrls/mctlcmd" auth:YES parameters:paraDict completionBlock:^(id response, NSError *error) {
        BOOL success =error?NO:YES;
        if (completionBlock) {
            completionBlock(success,error);
        }
    }];
}
@end
