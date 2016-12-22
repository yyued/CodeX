//
//  COXPixelLine.m
//  test
//
//  Created by 崔明辉 on 2016/12/22.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COXPixelLine.h"

@implementation COXPixelLine

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.contentMode = UIViewContentModeRedraw;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeRedraw;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    UIColor *color = self.color;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (color != nil && ctx != NULL) {
        [color setStroke];
        if (self.vertical) {
            CGContextSetLineWidth(ctx, 1.0);
            CGContextMoveToPoint(ctx, 0, 0);
            CGContextAddLineToPoint(ctx, 0, self.frame.size.height);
            CGContextStrokePath(ctx);
        }
        else {
            CGContextSetLineWidth(ctx, 1.0);
            CGContextMoveToPoint(ctx, 0, 0);
            CGContextAddLineToPoint(ctx, self.frame.size.width, 0);
            CGContextStrokePath(ctx);
        }
    }
}

@end
