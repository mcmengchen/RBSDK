//
//  RBTextField.m
//  Pudding
//
//  Created by william on 16/3/3.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import "RBTextField.h"

@implementation RBTextField


- (void)drawPlaceholderInRect:(CGRect)rect{
    UIColor *placeholderColor = [UIColor lightGrayColor];//设置颜色
    [placeholderColor setFill];
    
    CGRect placeholderRect = CGRectMake(rect.origin.x, (rect.size.height- (self.font.pointSize-2))*0.5, rect.size.width, self.font.pointSize);//设置距离
    
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    style.alignment = self.textAlignment;
    UIFont *font = [UIFont systemFontOfSize:self.font.pointSize - 2];
    NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:style,NSParagraphStyleAttributeName,font, NSFontAttributeName, placeholderColor, NSForegroundColorAttributeName, nil];
    
    [self.placeholder drawInRect:placeholderRect withAttributes:attr];
}

-(CGRect)textRectForBounds:(CGRect)bounds{
    
    return CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
}
-(CGRect)editingRectForBounds:(CGRect)bounds{
    return CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width - 25, bounds.size.height);
}



@end
