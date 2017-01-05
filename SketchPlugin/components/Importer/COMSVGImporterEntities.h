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

@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) CGFloat opacity;
@property (nonatomic, strong) NSString *fill;
@property (nonatomic, strong) NSString *fillRule;

@end

@interface COMSVGCanvasEntity : COMSVGBaseEntity

@property (nonatomic, assign) CGSize viewBox;
@property (nonatomic, strong) NSArray *layers;

- (void)parseWithElements:(NSArray *)elements options:(NSDictionary *)options;
- (void)exportToSketch;

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
