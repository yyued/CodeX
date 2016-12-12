//
//  UILabel+COXRuntime.m
//  test
//
//  Created by 崔明辉 on 2016/12/12.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "UILabel+COXRuntime.h"

@implementation COXLabel

- (void)setFontWithFamilyName:(NSString *)familyName fontSize:(CGFloat)fontSize {
    NSArray<NSString *> *names = [familyName componentsSeparatedByString:@","];
    for (NSString *name in names) {
        UIFont *font =
            [UIFont fontWithName:[name stringByReplacingOccurrencesOfString:@" " withString:@""] size:fontSize];
        if (font != nil) {
            self.font = font;
            return;
        }
    }
    self.font = [UIFont systemFontOfSize:fontSize];
}

- (void)setText:(NSString *)text {
    if (text != nil) {
        NSAttributedString *attrString =
            [[NSAttributedString alloc] initWithString:text attributes:[self defaultAttributes]];
        [super setAttributedText:attrString];
    } else {
        [super setText:nil];
    }
    [self.superview layoutSubviews];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self.superview layoutSubviews];
}

- (NSDictionary *)defaultAttributes {
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    NSMutableParagraphStyle *paraStyle = [NSMutableParagraphStyle new];
    paraStyle.lineBreakMode = self.lineBreakMode;
    paraStyle.alignment = self.textAlignment;
    if (self.lineSpace > 0) {
        paraStyle.lineSpacing = self.lineSpace;
    }
    if (self.underlineStyle != NSUnderlineStyleNone) {
        attrs[NSUnderlineStyleAttributeName] = @(self.underlineStyle);
    }
    if (self.deletelineStyle != NSUnderlineStyleNone) {
        attrs[NSStrikethroughStyleAttributeName] = @(self.deletelineStyle);
    }
    if (self.letterSpace > 0) {
        attrs[NSKernAttributeName] = @(self.letterSpace);
    }
    if (self.strokeColor != nil) {
        attrs[NSStrokeColorAttributeName] = self.strokeColor;
    }
    if (self.strokeWidth != 0) {
        attrs[NSStrokeWidthAttributeName] = @(self.strokeWidth);
    }
    if (self.textColor != nil) {
        attrs[NSForegroundColorAttributeName] = self.textColor;
    }
    if (self.font != nil) {
        attrs[NSFontAttributeName] = self.font;
    }
    attrs[NSParagraphStyleAttributeName] = [paraStyle copy];
    return [attrs copy];
}

- (CGSize)cox_intrinsicContentSize {
    CGFloat widthAdjust = self.lineBreakMode == NSLineBreakByClipping ? 1.0 : self.font.pointSize / 4.0;
    if (self.maxWidth > 0.0) {
        CGRect bounds =
            [self.attributedText boundingRectWithSize:CGSizeMake(self.maxWidth, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesDeviceMetrics
                                              context:NULL];
        return CGSizeMake(ceilf(bounds.size.width) + widthAdjust, ceilf(bounds.size.height) + 1.0);
    } else {
        CGRect bounds =
        [self.attributedText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesDeviceMetrics
                                          context:NULL];
        return CGSizeMake(ceilf(bounds.size.width) + widthAdjust, ceilf(bounds.size.height) + 1.0);
    }
    return CGSizeZero;
}

@end
