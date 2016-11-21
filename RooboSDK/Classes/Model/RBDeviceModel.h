//
//  RBDeviceModel.h
//  Pods
//
//  Created by baxiang on 16/11/12.
//
//

#import <Foundation/Foundation.h>
@class RBUserModel;
@interface RBDeviceModel : NSObject

/**
 设备ID
 */
@property (nonatomic,strong) NSString *device_id;

/**
 设备当前电量
 */
@property (nonatomic,assign) float battery;

/**
 安全防护开关
 */
@property (nonatomic,assign) BOOL  isdefense;

/**
 看家模式开关
 */
@property (nonatomic, assign) BOOL autodefense;

/**
 是不是管理员
 */
@property (nonatomic,assign) BOOL manager;

/**
 设备的名称
 */
@property (nonatomic,strong) NSString *name;

/**
 是否连接网络
 */
@property (nonatomic,assign) BOOL online;

/**
 是否在充电中
 */
@property (nonatomic,assign) BOOL power;

/**
 是否连接电源
 */
@property (nonatomic,assign) BOOL power_supply;
@end




@interface RBHardware : NSObject
@property (nonatomic,strong) NSString *hardwareType;
@property (nonatomic,strong) NSString *wifiName;
@property (nonatomic,strong) NSString *sn;
@property (nonatomic,strong) NSString *IPAddress;
@property (nonatomic,strong) NSString *MacAddress;
@end



@interface RBDeviceUser : NSObject
/**
 用户头像
 */
@property (nonatomic,strong) NSString *headimg;
/**
 用户名称
 */
@property (nonatomic,strong) NSString *name;

/**
   分为 管理员 和普通成员
 */
@property (nonatomic,assign) BOOL manager;

/**
 用户的uid
 */
@property (nonatomic,strong) NSString *userid;

@end


@interface RBDevicesDetail : RBDeviceModel
/**
 安防开始时间
 */
@property (nonatomic,strong) NSString *guard_start;

/**
 安防结束时间
 */
@property (nonatomic,strong) NSString *guard_end;

/**
 夜间模式开关
 */
@property (nonatomic,assign) BOOL night_switch;

/**
 夜间模式开始时间
 */
@property (nonatomic,strong) NSString *night_start;

/**
 夜间模式关闭时间
 */
@property (nonatomic,strong) NSString * night_end;

/**
  设备的音色
 */
@property (nonatomic,strong) NSString * timbre;

/**
 远程视频提示音
 */
@property (nonatomic,assign) BOOL  rvnotify;

/**
 音量大小
 */
@property (nonatomic,assign) float volume;
/**
     绑定当前的设备的用户组
 */
@property (nonatomic,strong) NSArray <RBDeviceUser*>*users;
@end
