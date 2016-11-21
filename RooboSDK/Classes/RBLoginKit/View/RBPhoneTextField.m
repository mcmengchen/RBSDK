//
//  RBPhoneTextField.m
//  JuanRoobo
//
//  Created by Zhi Kuiyu on 15/2/11.
//  Copyright (c) 2015年 Zhi Kuiyu. All rights reserved.
//

#import "RBPhoneTextField.h"
#define RBPhoneSep @" "

@interface RBPhoneTextField ()
@property (strong, nonatomic) NSRegularExpression   *nonNumericRegularExpression;
@property (nonatomic, strong) NSCharacterSet        *numberCharacterSet;

@end


@implementation RBPhoneTextField

- (id)init{
    if(self = [super init]){
        self.textColor = [UIColor whiteColor];
        _nonNumericRegularExpression    = [RBPhoneTextField nonNumericRegularExpression];
        _numberCharacterSet             = [RBPhoneTextField numberCharacterSet];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shouldChangeCharactersInRange:) name:UITextFieldTextDidChangeNotification object:nil];

    }
    
    return self;
}


- (NSString *)phoneText{
    return [self.attributedText.string stringByReplacingOccurrencesOfString:RBPhoneSep withString:@""];
}

- (id)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.textColor = [UIColor whiteColor];
        _nonNumericRegularExpression    = [RBPhoneTextField nonNumericRegularExpression];
        _numberCharacterSet             = [RBPhoneTextField numberCharacterSet];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shouldChangeCharactersInRange:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super initWithCoder:aDecoder]){
        _nonNumericRegularExpression    = [RBPhoneTextField nonNumericRegularExpression];
        _numberCharacterSet             = [RBPhoneTextField numberCharacterSet];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shouldChangeCharactersInRange:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}


#pragma mark - action: 根据范围去修改输入的样式，因为删除时候的 bug，注释。
- (void)shouldChangeCharactersInRange:(NSNotification *)sender{
//    UITextField * textField = sender.object;
//    if([textField isKindOfClass:[RBPhoneTextField class]]){
//        NSString *replacedString = textField.attributedText.string;
//        NSString *numberOnlyString = [self numberOnlyStringWithString:replacedString];
////        if (numberOnlyString.length >= 11) {
//////            NSString * str  = [NSString stringWithFormat:@"%@%@",[numberOnlyString substringToIndex:10],[numberOnlyString substringFromIndex:numberOnlyString.length -1]];
////            NSString * str  = [NSString stringWithFormat:@"%@",[numberOnlyString substringToIndex:11]];
////            textField.attributedText = [self getResultAttributeString:str];
////            return;
////            
////        }
//        
//        
//        textField.attributedText = [self getResultAttributeString:numberOnlyString];
//
//    }
    

}



+ (NSRegularExpression *)nonNumericRegularExpression
{
    return [NSRegularExpression regularExpressionWithPattern:@"[^0-9]+" options:0 error:nil];
}

+ (NSCharacterSet *)numberCharacterSet
{
    return [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
}

#pragma mark - Private Methods
- (NSAttributedString *)getResultAttributeString:(NSString *)string{
    NSRange rang1 = NSMakeRange(NSNotFound, 0);
    NSRange rang2 = NSMakeRange(NSNotFound, 0);
    NSMutableString * result = [[NSMutableString alloc] initWithString:string];
    if(string.length> 7){
        [result insertString:RBPhoneSep atIndex:7];
        [result insertString:RBPhoneSep atIndex:3];
      
        rang1 = NSMakeRange(8, 1);
        rang2 = NSMakeRange(3, 1);
    }else if(string.length > 3){
        [result insertString:RBPhoneSep atIndex:3];
        rang2 = NSMakeRange(3, 1);
    }
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc]initWithString:result];
    if(rang1.location != NSNotFound){
        [title addAttribute:NSKernAttributeName value: @(.5f) range:NSMakeRange(rang1.location - 1, 2)];
        [title addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:0.837 alpha:1.000] range:rang1];
    }
    
    if(rang2.location != NSNotFound){
        [title addAttribute:NSKernAttributeName value: @(.5f) range:NSMakeRange(rang2.location - 1, 2)];
        [title addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:0.837 alpha:1.000] range:rang2];
    }
   
    return title;

}

- (NSString *)stringByRemovingNonNumericCharacters:(NSString *)string
{
    return [self.nonNumericRegularExpression stringByReplacingMatchesInString:string
                                                                      options:0
                                                                        range:NSMakeRange(0, string.length)
                                                                 withTemplate:@""];
}

- (NSString *)numberOnlyStringWithString:(NSString *)string
{
    return [self.nonNumericRegularExpression stringByReplacingMatchesInString:string
                                                                      options:0
                                                                        range:NSMakeRange(0, string.length)
                                                                 withTemplate:@""];
}
-(CGRect)textRectForBounds:(CGRect)bounds{
    
    return CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
}
-(CGRect)editingRectForBounds:(CGRect)bounds{
    return CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width - 25, bounds.size.height);
}

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

@end
