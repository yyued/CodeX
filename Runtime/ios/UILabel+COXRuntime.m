//
//  UILabel+COXRuntime.m
//  test
//
//  Created by 崔明辉 on 2016/12/12.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "UILabel+COXRuntime.h"

@implementation COXLabel

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.fontFamily = [coder decodeObjectForKey:@"fontFamily"];
        self.fontSize = [coder decodeDoubleForKey:@"fontSize"];
        self.letterSpacing = [coder decodeDoubleForKey:@"letterSpacing"];
        self.cox_lineSpacing = [coder decodeDoubleForKey:@"cox_lineSpacing"];
        self.underlineStyle = [coder decodeIntegerForKey:@"underlineStyle"];
        self.deletelineStyle = [coder decodeIntegerForKey:@"deletelineStyle"];
        self.strokeColor = [coder decodeObjectForKey:@"strokeColor"];
        self.strokeWidth = [coder decodeDoubleForKey:@"strokeWidth"];
        self.maxWidth = [coder decodeDoubleForKey:@"maxWidth"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.fontFamily forKey:@"fontFamily"];
    [aCoder encodeDouble:self.fontSize forKey:@"fontSize"];
    [aCoder encodeDouble:self.letterSpacing forKey:@"letterSpacing"];
    [aCoder encodeDouble:self.cox_lineSpacing forKey:@"cox_lineSpacing"];
    [aCoder encodeInteger:self.underlineStyle forKey:@"underlineStyle"];
    [aCoder encodeInteger:self.deletelineStyle forKey:@"deletelineStyle"];
    [aCoder encodeObject:self.strokeColor forKey:@"strokeColor"];
    [aCoder encodeDouble:self.strokeWidth forKey:@"strokeWidth"];
    [aCoder encodeDouble:self.maxWidth forKey:@"maxWidth"];
}

- (id)copy {
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
}

- (void)setFontWithFamilyName:(NSString *)familyName fontSize:(CGFloat)fontSize {
    self.fontFamily = familyName;
    self.fontSize = fontSize;
    [self resetFont];
}

- (void)resetFont {
    NSArray<NSString *> *names = [self.fontFamily componentsSeparatedByString:@","];
    for (NSString *name in names) {
        UIFont *font =
        [UIFont fontWithName:[name stringByReplacingOccurrencesOfString:@" " withString:@""]
                        size:self.fontSize];
        if (font != nil) {
            self.font = font;
            return;
        }
    }
    self.font = [UIFont systemFontOfSize:self.fontSize];
}

- (void)setFontFamily:(NSString *)fontFamily {
    _fontFamily = fontFamily;
    [self resetFont];
}

- (void)setFontSize:(CGFloat)fontSize {
    _fontSize = fontSize;
    [self resetFont];
}

- (void)setText:(NSString *)text {
    if (text != nil) {
        NSAttributedString *attrString =
            [[NSAttributedString alloc] initWithString:text attributes:[self defaultAttributes]];
        [super setAttributedText:attrString];
    } else {
        [super setText:nil];
    }
    [self.cox_constraint setNeedsLayout];
    [self.superview layoutSubviews];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self.cox_constraint setNeedsLayout];
    [self.superview layoutSubviews];
}

- (NSDictionary *)defaultAttributes {
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    NSMutableParagraphStyle *paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paraStyle.lineBreakMode = self.lineBreakMode;
    paraStyle.alignment = self.textAlignment;
    if (self.cox_lineSpacing > 0) {
        paraStyle.minimumLineHeight = self.cox_lineSpacing;
        paraStyle.maximumLineHeight = self.cox_lineSpacing;
        CGFloat offset = ((self.cox_lineSpacing + self.font.descender) - ((self.cox_lineSpacing - self.font.lineHeight) / 2.0 + self.font.ascender)) / 2.0;
        attrs[NSBaselineOffsetAttributeName] = @(offset);
    }
    if (self.underlineStyle != NSUnderlineStyleNone) {
        attrs[NSUnderlineStyleAttributeName] = @(self.underlineStyle);
    }
    if (self.deletelineStyle != NSUnderlineStyleNone) {
        attrs[NSStrikethroughStyleAttributeName] = @(self.deletelineStyle);
    }
    if (self.letterSpacing > 0) {
        attrs[NSKernAttributeName] = @(self.letterSpacing);
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
        CGSize size = [self sizeThatFits:CGSizeMake(self.maxWidth, CGFLOAT_MAX)];
        return CGSizeMake(ceilf(size.width) + widthAdjust, ceilf(size.height) + 1.0);
    } else {
        CGSize size = [self sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
        return CGSizeMake(ceilf(size.width) + widthAdjust, ceilf(size.height) + 1.0);
    }
    return CGSizeZero;
}

- (void)setAttributesWithRange:(NSRange)range referenceLabel:(COXLabel *)referenceLabel {
    NSMutableAttributedString *attributedText = [self.attributedText mutableCopy];
    [attributedText addAttributes:[referenceLabel defaultAttributes] range:range];
    self.attributedText = attributedText;
}

@end
