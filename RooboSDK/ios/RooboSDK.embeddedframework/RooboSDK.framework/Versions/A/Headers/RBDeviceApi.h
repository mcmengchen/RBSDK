//
//  RBDeviceApi.h
//  Pods
//
//  Created by baxiang on 16/11/12.
//
//

#import <Foundation/Foundation.h>
#import "RBDeviceModel.h"
typedef NS_ENUM(NSInteger,RBNightSetting){
    RBNightSettingSwitch = 0, // 设置夜间模式开关
    RBNightSettingTime      // 设置夜间模式时间段

};


typedef NS_ENUM(NSInteger,RBEmojiType){
    RBEmoji_Moe = 2, //呆萌
    RBEmoji_Angry = 3,//愤怒
    RBEmoji_Helpless =5,//无语
    RBEmoji_Wink = 6, //挤眼
    RBEmoji_Amazed = 7, //惊讶
    RBEmoji_happy = 8,//开心
    RBEmoji_Fear = 9,//恐惧
    RBEmoji_Cry =10,  //伤心
    RBEmoji_Sleep =12, //睡觉
    RBEmoji_Love = 13,   //喜爱
    RBEmoji_Query = 14, //疑问
    RBEmoji_Dizzy = 15, //眩晕
};


typedef NS_ENUM(NSUInteger, RBModifyNetType) {
    RBModifyNetType_BindDevice, //绑定设备配网
    RBModifyNetType_ModifyNet,  //修改设备网络
};


@interface RBDeviceApi : NSObject

#pragma mark ------------------- 设备配网 ------------------------

/**
 *  打开设备声波配网功能
 *
 *  @param deviceID        设备 ID
 *  @param isModifyNet     网络类型   RBModifyNetType_ModifyNet：修改网络，
                                    RBModifyNetType_BindDevice：绑定设备配网
 */
+ (void)openVoiceConfigNetWithDeviceID:(NSString *_Nonnull) deviceID type:(RBModifyNetType)netType completionBlock:(nullable void (^)(BOOL isSucceed,NSError *error)) completionBlock;


/**
 *  播放声波配网文件
 *
 *  @param wifiName wifi 名称
 *  @param wifiPsd   wifi 密码
 */
+ (void)playVoiceConfigNetFileWithWifiName:(NSString *_Nonnull)wifiName wifiPsd:(NSString * _Nonnull)wifiPsd;


/**
 *  获取绑定配网结果
 *
 *  @description 此接口会不断通过completionBlock 返回结果，调用此接口时需等待最后的回调，
                 当 result 为 success 或 failure 时表示此次调用结束。
 *  @param completionBlock 回调
 *  @param completionBlock 中的参数：
                            isSucceed: 绑定配网是否成功
                            error：错误信息
                            dict:result状态  -> wait     正在获取结果
                                            -> failure  失败
                                            -> success  成功
                                  msg 详情描述
 *
 */
+ (void)startGetVoiceConfigNetResultBlock:(nullable void (^)(BOOL isSucceed,NSDictionary * dict,NSError *error)) completionBlock;

/**
 *  获取修改网络结果
 *
 *  @description 此接口会不断通过completionBlock 返回结果，调用此接口时需等待最后的回调，
                 当 result 为success 或failure 时表示此次调用结束。
 *  @param completionBlock 回调
 *  @param completionBlock 中的参数：
                            isSucceed: 修改网络是否成功
                            error：错误信息
                            dict:result状态  -> wait     正在获取结果
                                            -> failure  失败
                                            -> success  成功
                                  msg 详情描述
 *
 */
+ (void)startGetModifyNetResultBlock:(nullable void (^)(BOOL isSucceed,NSDictionary * dict,NSError *error))completionBlock;


#pragma mark ------------------- 设备权限 ------------------------

/**
 更改管理员

 @param deviceID 设备ID
 @param userID 用户的ID
 */
+ (void)changeManager:(NSString *_Nonnull)deviceID userID:(NSString *_Nonnull)userID completionBlock:(nullable void (^)(BOOL isSucceed, NSError * error))completionBlock;

/**
    删除所绑定的设备

 @param deviceID 设备ID
 */
+ (void)deleteOwnDevice:(NSString *_Nonnull) deviceID  completionBlock:(nullable void (^)(BOOL isSucceed,NSError *error)) completionBlock;

/**
   添加其他用户到设备成员组里面

 @param userPhone 用户的手机号码
 */
+ (void)addUser:(NSString *_Nonnull)userPhone deviceID:(NSString*_Nonnull)deviceID completionBlock:(nullable void (^)(id response,NSError *error)) completionBlock;

/**
   从当前设备成员组中删除用户

 @param userid 用户 id
 */
+ (void)deleteUser:(NSString *_Nonnull)userid deviceID:(NSString*_Nonnull)deviceID  completionBlock:(nullable void (^)(id response,NSError *error)) completionBlock;

#pragma mark ------------------- 设备信息 ------------------------
/**
 获取当前用户的所有设备
 */
+ (void)fetchAllDevices:(nullable void(^)(NSArray <RBDeviceModel*>*device,NSError *error))completionBlock;

/**
  获取设备硬件信息
 @param mcid 设备的ID数据
 */
+ (void)fetchHardwareInfo:(NSString*_Nonnull)deviceID completion:(nullable void(^)(RBHardware*device,NSError *error))completionBlock;

/**
 获取设备的信息

 @param deviceID 设备的ID
 */
+ (void)fetchDeviceDetail:(NSString *_Nonnull) deviceID completionBlock:(nullable void (^)(RBDevicesDetail *detail,NSError *error)) completionBlock;

#pragma mark ------------------- 设备控制 ------------------------

/**
  发送表情
 @param deviceID 设备ID
 @param emojiType 表情ID 
 */
+ (void)sendEmoji:(NSString *_Nonnull)deviceID emojiType:(RBEmojiType) emojiType completionBlock:(nullable void (^)(BOOL isSucceed,NSError *error)) completionBlock;

/**
 发送文本内容

 @param deviceID 设备ID
 @param text 文字内容
 */
+ (void)sendTTS:(NSString *_Nonnull)deviceID content:(NSString *_Nonnull)text completionBlock:(nullable void (^)(BOOL isSucceed,NSError *error)) completionBlock;
/**
 旋转设备

 @param deviceID 设备ID
 @param angle 角度值
 */
+ (void)rotateDevice:(NSString *_Nonnull)deviceID angle:(float)angle completionBlock:(nullable void (^)(BOOL isSucceed,NSError *error)) completionBlock;
/**
 重启设备

 @param completionBlock isSucceed 重启是否成功 error 错误信息
 */
+ (void)restart:(NSString *_Nonnull) deviceID  completionBlock:(nullable void (^)(BOOL isSucceed,NSError *error)) completionBlock;

/**
 开启安全防护
 @param deviceID 设备的ID
 @param enable 是否打开

 */
+ (void)switchSafetyState:(NSString* _Nonnull)deviceID isOn:(BOOL)isOn completionBlock:(nullable void (^)(BOOL isSucceed,NSError *error)) completionBlock;

/**
 修改设备的安防时间段

 @param deviceID 设备的ID
 @param startTime 开始时间
 @param endTime 结束时间
 */
+ (void)updateSafetyTime:(NSString*_Nonnull)deviceID startTime:(NSString * _Nonnull)startTime endTime:(NSString *_Nonnull)endTime  completionBlock:(void (^)(BOOL isSucceed,NSError *error)) completionBlock;

/**
 设置夜间模式开关 不管是设置时间段和设置夜间模式开关 都需要传送开始时间和结束时间
 
 @param deviceID 设备ID
 @param settingType 设置时间段和设置夜间模式开关
 @param switchState 夜间模式的开关
 @param startTime 开始时间 格式@"07:22"
 @param endTime 结束时间   格式@"10：00"
 */
+(void)updateNightMode:(NSString *_Nonnull) deviceID nightSetting:(RBNightSetting)settingType switchState:(BOOL)switchState startTime:(NSString * _Nonnull)startTime endTime:(NSString *_Nonnull)endTime completionBlock:(nullable void (^)(BOOL isSucceed,NSError *error)) completionBlock;

#pragma mark ------------------- 设备设置 ------------------------

/**
 修改设备的名称
 @param deviceID  设备的ID
 @param newName 新的名称
 */
+ (void)updateDeviceName:(NSString*_Nonnull)deviceID name:(NSString *_Nonnull)newName completionBlock:(nullable void (^)(BOOL isSucceed,NSError *error)) completionBlock;

/**
  进入视频连接成功的声音开关
 
 @param deviceID 设备的ID
 @param isOn 打开或者关闭
 */
+ (void)switchVideoConnetVoice:(NSString *_Nonnull) deviceID isOn:(BOOL) isOn completionBlock:(nullable void (^)(BOOL isSucceed,NSError *error)) completionBlock;
/**
 修改设备音量

 @param deviceID 设备的ID
 @param voiceValue 音量值 最小值0 最大值100

 */
+ (void)updateVolume:(NSString *_Nonnull) deviceID voice:(float)voiceValue completionBlock:(nullable void (^)(BOOL isSucceed,NSError *error)) completionBlock;

/**
 修改设备的声音音色类型

 @param deviceID 设备的id
 @param soundName 字符串  NANNAN 或 ROOBO_BOY
 */
+ (void)updateSound:(NSString *_Nonnull ) deviceID  soundName:(NSString* _Nonnull)soundName completionBlock:(nullable void (^)(BOOL isSucceed,NSError *error)) completionBlock;
@end
