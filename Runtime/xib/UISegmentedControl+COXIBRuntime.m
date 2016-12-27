//
//  UISegmentedControl+COXIBRuntime.m
//  test
//
//  Created by 崔明辉 on 2016/12/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "UISegmentedControl+COXIBRuntime.h"

@implementation UISegmentedControl (COXIBRuntime)

- (NSString *)cox_titles {
    return nil;
}

- (void)setCox_titles:(NSString *)cox_titles {
    [self removeAllSegments];
    [[cox_titles componentsSeparatedByString:@","] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self insertSegmentWithTitle:obj atIndex:0 animated:NO];
    }];
}

- (UIColor *)cox_selectedColor {
    return nil;
}

- (void)setCox_selectedColor:(UIColor *)cox_selectedColor {
    if (cox_selectedColor == nil) {
        return;
    }
    [self setTitleTextAttributes:@{
                                   NSForegroundColorAttributeName: cox_selectedColor,
                                   }
                        forState:UIControlStateSelected];
}

@end
