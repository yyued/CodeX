//
//  UIView+COXIBRuntime.m
//  test
//
//  Created by 崔明辉 on 2016/12/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "UIView+COXIBRuntime.h"

@implementation UIView (COXIBRuntime)

- (UIColor *)cox_borderColor {
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void)setCox_borderColor:(UIColor *)cox_borderColor {
    self.layer.borderColor = [cox_borderColor CGColor];
}

- (BOOL)cox_constraintEnabled {
    return NO;
}

- (void)setCox_constraintEnabled:(BOOL)cox_constraintEnabled {
    if (cox_constraintEnabled) {
        [self setCox_constraint:[COXConstraint new]];
    }
    else {
        [self setCox_constraint:nil];
    }
}

@end
