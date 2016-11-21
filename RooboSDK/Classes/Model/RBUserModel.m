//
//  RBUserModel.m
//  Pods
//
//  Created by baxiang on 16/11/12.
//
//

#import "RBUserModel.h"
#import "RBDeviceModel.h"
@implementation RBUserModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"name" : @"data.name",
             @"devices":@"data.mcids",
             @"headimg":@"data.headimg"};
}
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"devices" : [RBDeviceModel class]};
}

@end
