//
//  RBUserModel.h
//  Pods
//
//  Created by baxiang on 16/11/12.
//
//

#import <Foundation/Foundation.h>

@class RBDeviceModel;
/**
   用户基本信息
 */
@interface RBUserModel : NSObject

/**
 用户头像
 */
@property (nonatomic,strong) NSString *headimg;

/**
 用户名称
 */
@property (nonatomic,strong) NSString *name;

/**
 用户所拥有的设备
 */
@property (nonatomic,strong) NSArray <RBDeviceModel*> *devices;

@end
