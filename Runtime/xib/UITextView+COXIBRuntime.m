//
//  UITextView+COXIBRuntime.m
//  test
//
//  Created by 崔明辉 on 2016/12/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "UITextView+COXIBRuntime.h"

@implementation COXUITextView

- (void)awakeFromNib {
    [super awakeFromNib];
    COXLabel *titleLabel = [self viewWithTag:-1];
    if (titleLabel != nil && [titleLabel isKindOfClass:[COXLabel class]]) {
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self setAttributedText:titleLabel.attributedText];
        [self setTypingAttributes:[titleLabel defaultAttributes]];
        [titleLabel removeFromSuperview];
    }
}

- (void)setCox_inset:(CGFloat)cox_inset {
    _cox_inset = cox_inset;
    [self setTextContainerInset:UIEdgeInsetsMake(cox_inset, cox_inset - 4, cox_inset, cox_inset - 4)];
}

@end
