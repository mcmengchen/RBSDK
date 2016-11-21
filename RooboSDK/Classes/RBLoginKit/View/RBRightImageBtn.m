//
//  PDRightImageBtn.m
//  Pudding
//
//  Created by william on 16/3/14.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import "RBRightImageBtn.h"
#import "UIView+RBLayoutExtension.h"
@implementation RBRightImageBtn

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)layoutSubviews{
    [super layoutSubviews];
    if (_isTitleLeft) {
        self.titleLabel.frame = CGRectMake(0, 0, self.titleLabel.frame.size.width, self.height);
        self.imageView.frame = CGRectMake(self.titleLabel.right+_offsetX, (self.height - self.imageView.height)*0.5, self.imageView.width, self.imageView.height);
    }else{
        self.titleLabel.frame = CGRectMake((self.width - self.titleLabel.width - self.imageView.width)*0.5, 0, self.titleLabel.frame.size.width, self.height);
        self.imageView.frame = CGRectMake(self.titleLabel.right, (self.height - self.imageView.height)*0.5, self.imageView.width, self.imageView.height);
    }

    
    
}


@end
