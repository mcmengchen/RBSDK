//
//  RBLabButton.m
//  Pudding
//
//  Created by william on 16/3/9.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import "RBLabButton.h"

@implementation RBLabButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)layoutSubviews{
    [super layoutSubviews];
    self.titleLabel.frame = self.bounds;
    
}

@end
