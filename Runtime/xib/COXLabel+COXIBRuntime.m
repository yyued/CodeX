//
//  COXLabel+COXIBRuntime.m
//  ttt
//
//  Created by 崔 明辉 on 2016/12/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COXLabel+COXIBRuntime.h"

@implementation COXIBLabel

- (void)awakeFromNib {
    [super awakeFromNib];
    NSMutableAttributedString *mutableText = [self.attributedText mutableCopy];
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[COXIBLabel class]]) {
            [mutableText setAttributes:[(COXIBLabel *)obj defaultAttributes]
                                 range:NSMakeRange([(COXIBLabel *)obj rangeLocation], [(COXIBLabel *)obj rangeLength])];
            [obj removeFromSuperview];
        }
    }];
    self.attributedText = mutableText;
}

@end
