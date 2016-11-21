//
//  NSObject+RBAdd.h
//  Pods
//
//  Created by baxiang on 16/11/13.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (RBAdd)
- (NSDictionary *)rb_dictionaryVerify;
- (NSString *)stringForKey:(NSString *)key defaultValue:(NSString *)def;
- (BOOL)isEmpty;
@end
