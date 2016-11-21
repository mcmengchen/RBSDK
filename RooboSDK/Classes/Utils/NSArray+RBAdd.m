//
//  NSArray+RBAdd.m
//  Pods
//
//  Created by baxiang on 16/11/13.
//
//

#import "NSArray+RBAdd.h"

@implementation NSArray (RBAdd)
- (id)objectOrNilAtIndex:(NSUInteger)index {
    return index < self.count ? self[index] : nil;
}
@end
