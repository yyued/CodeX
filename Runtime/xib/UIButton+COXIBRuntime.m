//
//  UIButton+COXIBRuntime.m
//  test
//
//  Created by 崔明辉 on 2016/12/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "UIButton+COXIBRuntime.h"
#import <objc/runtime.h>

@implementation COXUIButton

- (void)awakeFromNib {
    [super awakeFromNib];
    COXLabel *titleLabel = [self viewWithTag:-1];
    if (titleLabel != nil) {
        [self setAttributedTitle:titleLabel.attributedText forState:UIControlStateNormal];
        NSMutableAttributedString *highlighted = [titleLabel.attributedText mutableCopy];
        UIColor *textColor = titleLabel.defaultAttributes[NSForegroundColorAttributeName];
        if (textColor != nil) {
            textColor = [textColor colorWithAlphaComponent:0.3];
            [highlighted setAttributes:@{
                                         NSForegroundColorAttributeName: textColor,
                                         }
                                 range:NSMakeRange(0, [highlighted.string length])];
            [self setAttributedTitle:highlighted forState:UIControlStateHighlighted];
        }
    }
    [titleLabel removeFromSuperview];
}

@end
