//
//  RBNetworkManager.h
//  Pods
//
//  Created by baxiang on 16/11/12.
//
//

#import <Foundation/Foundation.h>
UIKIT_EXTERN  NSString * const RBResponseErrorDomain;
/**
    网络请求管理类
 */
@interface RBNetworkManager : NSObject

+(BOOL)parameterIsError:(id)parameter type:(Class)classType error:(NSError**)error;
+(void)POST:(NSString*)urlStr auth:(BOOL)isAuth parameters:(NSDictionary*) parameters completionBlock:(void (^)(id response,NSError *error)) completionBlock;


+(void)UPLOAD:(NSString *)urlStr auth:(BOOL)isAuth parameters:(NSDictionary *)parameters file:(id)file progressBlock:(void(^)(NSProgress *))progressBlock completionBlock:(void (^)(id, NSError *))completionBlock;

@end
