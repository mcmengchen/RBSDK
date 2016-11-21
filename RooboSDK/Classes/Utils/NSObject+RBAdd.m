//
//  NSObject+RBAdd.m
//  Pods
//
//  Created by baxiang on 16/11/13.
//
//

#import "NSObject+RBAdd.h"

@implementation NSObject (RBAdd)

- (NSDictionary *)rb_dictionaryVerify {
    if (!self || self == (id)kCFNull) return nil;
    NSDictionary *dic = nil;
    NSData *jsonData = nil;
    if ([self isKindOfClass:[NSDictionary class]]) {
        dic = self;
    } else if ([self isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)self dataUsingEncoding : NSUTF8StringEncoding];
    } else if ([self isKindOfClass:[NSData class]]) {
        jsonData = self;
    }
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
    }
    return dic;
}

- (NSString *)stringForKey:(NSString *)key defaultValue:(NSString *)def {
    if (![self isKindOfClass:[NSDictionary class]])return def;
    if (!key) return def;
    NSDictionary *dict =(NSDictionary*) self;
    id value = dict[key];
    if (!value || value == [NSNull null]) return def;
    if ([value isKindOfClass:[NSString class]]) return value;
    if ([value isKindOfClass:[NSNumber class]]) return ((NSNumber *)value).description;
    return def;
}
- (BOOL)isEmpty {
    return (self == nil
             || [self isKindOfClass:[NSNull class]]
             || ([self respondsToSelector:@selector(length)]
                 && [(NSData *)self length] == 0)
             || ([self respondsToSelector:@selector(count)]
                 && [(NSArray *)self count] == 0));
}
@end
