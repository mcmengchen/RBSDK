//
//  RBLoginKitProtocol.m
//  Pods
//
//  Created by william on 16/11/15.
//
//

#import "RBLoginKitManager.h"

@implementation RBLoginKitManager
+(instancetype)sharedManager{
    
    
    return [[self alloc]init];
}
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static RBLoginKitManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [super allocWithZone:zone];
    });
    return manager;
}










@end
