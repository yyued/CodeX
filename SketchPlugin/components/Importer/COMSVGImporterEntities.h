//
//  COMSVGImporterEntities.h
//  components
//
//  Created by 崔明辉 on 2017/1/5.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AppKit/AppKit.h>

@interface COMSVGBaseEntity : NSObject

@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, strong) id styleGeneric;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) NSString *originX;
@property (nonatomic, assign) NSString *originY;
@property (nonatomic, assign) CGFloat opacity;
@property (nonatomic, strong) NSString *fill;
@property (nonatomic, strong) NSString *fillRule;
@property (nonatomic, strong) NSString *stroke;
@property (nonatomic, strong) NSArray *strokeDashArray;
@property (nonatomic, strong) NSString *strokeLineCap;
@property (nonatomic, strong) NSString *strokeLineJoin;
@property (nonatomic, assign) CGFloat strokeMiterLimit;
@property (nonatomic, assign) CGFloat strokeWidth;


@end

@interface COMSVGCanvasEntity : COMSVGBaseEntity

@property (nonatomic, assign) CGSize viewBox;
@property (nonatomic, strong) NSArray *layers;

- (void)parseWithElements:(NSArray *)elements options:(NSDictionary *)options;
- (void)exportToSketch:(CGFloat)toWidth;

@end

@interface COMSVGTextEntity : COMSVGBaseEntity

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *textAlignment;
@property (nonatomic, strong) NSString *textColor;
@property (nonatomic, strong) NSString *fontFamily;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, strong) NSString *fontStyle;
@property (nonatomic, assign) CGFloat fontWeight;

@end

@interface COMSVGImageEntity : COMSVGBaseEntity

@property (nonatomic, strong) NSImage *image;

@end

@interface COMSVGPathEntity : COMSVGBaseEntity

@property (nonatomic, strong) NSBezierPath *bezierPath;

@end

@interface COMSVGCircleEntity : COMSVGPathEntity

@end
