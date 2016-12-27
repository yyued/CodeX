//
//  UITextField+COXIBRuntime.m
//  test
//
//  Created by 崔明辉 on 2016/12/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "UITextField+COXIBRuntime.h"

@implementation COXUITextField

- (void)awakeFromNib {
    [super awakeFromNib];
    COXLabel *titleLabel = [self viewWithTag:-1];
    if (titleLabel != nil && [titleLabel isKindOfClass:[COXLabel class]]) {
        [self setDefaultTextAttributes:[titleLabel defaultAttributes]];
        [titleLabel removeFromSuperview];
    }
    COXLabel *placeholderLabel = [self viewWithTag:-2];
    if (placeholderLabel != nil && [placeholderLabel isKindOfClass:[COXLabel class]]) {
        [self setAttributedPlaceholder:[placeholderLabel attributedText]];
        [placeholderLabel removeFromSuperview];
    }
}

- (void)setCox_leftPadding:(CGFloat)cox_leftPadding {
    _cox_leftPadding = cox_leftPadding;
    self.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cox_leftPadding, 0)];
    self.leftViewMode = UITextFieldViewModeAlways;
}

@end
