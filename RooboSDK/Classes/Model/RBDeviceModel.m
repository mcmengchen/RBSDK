//
//  RBDeviceModel.m
//  Pods
//
//  Created by baxiang on 16/11/12.
//
//

#import "RBDeviceModel.h"
#import "RBUserModel.h"
#import "NSArray+RBAdd.h"
#import "NSObject+RBAdd.h"
@implementation RBDeviceModel
@end

@implementation RBHardware : NSObject
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic{
    NSDictionary * dataDict = dic[@"data"];
    NSArray *list = dataDict[@"list"];
    for (NSDictionary *dict in list) {
       NSString *key = [dict stringForKey:@"key" defaultValue:nil];
        if ([key isEqualToString:@"布丁型号"] ) {
            _hardwareType = [dict stringForKey:@"val" defaultValue:nil] ;
        }else if ([key isEqualToString:@"链接的WiFi"] ) {
            _wifiName =  [dict stringForKey:@"val" defaultValue:nil] ;;
        }else if ([key isEqualToString:@"底部SN号"] ) {
            _sn =  [dict stringForKey:@"val" defaultValue:nil] ;;
        }else if ([key isEqualToString:@"IP地址"] ) {
            _IPAddress =  [dict stringForKey:@"val" defaultValue:nil] ;;
        }else if ([key  isEqualToString:@"MAC地址"] ) {
            _MacAddress =  [dict stringForKey:@"val" defaultValue:nil] ;;
        }
    }
    return YES;
}
@end
@implementation RBDeviceUser
@end
@implementation RBDevicesDetail
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"users" : @"data.users",
             @"autodefense" : @"data.autodefense",
             @"battery" : @"data.battery",
             @"isdefense" : @"data.isdefense",
             @"name" : @"data.name",
             @"online" : @"data.online",
             @"power_supply" : @"data.power_supply",
             @"rvnotify" : @"data.rvnotify",
             @"timbre" : @"data.timbre",
             @"volume" : @"data.volume",
             @"wifissid" : @"data.wifissid",
             @"wifissid" : @"data.wifissid",
             @"device_id" : @"data.mcid",
             @"power" : @"data.power",
             @"timbre" : @"data.timbre",
             @"volume" : @"data.volume",
             };
}
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSDictionary * dataDict = dic[@"data"];
    NSArray *guard_times = dataDict[@"guard_times"];
    if ([guard_times isKindOfClass:[NSArray class]]){
        NSDictionary *timeDict  = [guard_times objectOrNilAtIndex:0];
        _guard_start= [timeDict stringForKey:@"start" defaultValue:nil];
        _guard_end= [timeDict stringForKey:@"end" defaultValue:nil];
    }
     NSDictionary *nightmode = dataDict[@"nightmode"];
    _night_switch = [[nightmode stringForKey:@"state" defaultValue:@"0"] boolValue];
     NSArray *timeRang = [nightmode objectForKey:@"timerang"];
    if ([timeRang isKindOfClass:[NSArray class]]){
        NSDictionary *timeDict  = [timeRang objectOrNilAtIndex:0];
        _night_start = [timeDict stringForKey:@"start" defaultValue:nil];
        _night_end = [timeDict stringForKey:@"end" defaultValue:nil];
    }
    return YES;
}
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"users" : [RBDeviceUser class]};
}
@end
