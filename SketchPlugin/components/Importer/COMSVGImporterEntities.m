//
//  COMSVGImporterEntities.m
//  components
//
//  Created by 崔明辉 on 2017/1/5.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "COMSVGImporterEntities.h"
#import "HexColors.h"
#import <MCSketchPluginFramework/MCSketchPluginFramework.h>
#import <SVGKit/SVGKit.h>
#import "SKUBezierPath+SVG.h"

@implementation NSBezierPath (X)

- (void)addQuadCurveToPoint:(CGPoint)QP2 controlPoint:(CGPoint)QP1
{
    CGPoint QP0 = [self currentPoint];
    CGPoint CP3 = QP2;
    CGPoint CP1 = CGPointMake(
                              QP0.x + ((2.0 / 3.0) * (QP1.x - QP0.x)),
                              QP0.y + ((2.0 / 3.0) * (QP1.y - QP0.y))
                              );
    CGPoint CP2 = CGPointMake(
                              QP2.x + (2.0 / 3.0) * (QP1.x - QP2.x),
                              QP2.y + (2.0 / 3.0) * (QP1.y - QP2.y)
                              );
    [self curveToPoint:CP3 controlPoint1:CP1 controlPoint2:CP2];
}

@end

static void sPathApplier(void *info, const CGPathElement *element)
{
    NSBezierPath *path = (__bridge NSBezierPath *)info;
    
    switch (element->type) {
        case kCGPathElementMoveToPoint:
            [path moveToPoint:element->points[0]];
            break;
            
        case kCGPathElementAddLineToPoint:
            [path lineToPoint:element->points[0]];
            break;
            
        case kCGPathElementAddQuadCurveToPoint:
            [path addQuadCurveToPoint: element->points[1]
                         controlPoint: element->points[0]];
            
            break;
            
        case kCGPathElementAddCurveToPoint:
            [path curveToPoint: element->points[2]
                 controlPoint1: element->points[0]
                 controlPoint2: element->points[1]];
            
            break;
            
        case kCGPathElementCloseSubpath:
            [path closePath];
            break;
    }
}

@interface NSString (SVGColor)

- (NSString *)svg_color;

@end

@interface MSShapeGroup (COMSVGImporter)

+ (id)shapeWithBezierPath:(id)arg1;

@end

@implementation COMSVGBaseEntity

+ (COMSVGBaseEntity *)parse:(NSDictionary *)element {
    NSMutableDictionary *mutableElement = [element mutableCopy];
    [element enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSNull class]]) {
            [mutableElement removeObjectForKey:key];
        }
    }];
    element = [mutableElement copy];
    if ([element[@"type"] isEqualToString:@"image"]) {
        return [COMSVGImageEntity parse:element];
    }
    else if ([element[@"type"] isEqualToString:@"text"]) {
        return [COMSVGTextEntity parse:element];
    }
    else if ([element[@"type"] isEqualToString:@"path"]) {
        return [COMSVGPathEntity parse:element];
    }
    else if ([element[@"type"] isEqualToString:@"circle"]) {
        return [COMSVGCircleEntity parse:element];
    }
    return nil;
}

- (void)parse:(NSDictionary *)element {
    {
        CGRect frame = CGRectZero;
        frame.origin.x = [element[@"left"] floatValue];
        frame.origin.y = [element[@"top"] floatValue];
        frame.size.width = [element[@"width"] floatValue];
        frame.size.height = [element[@"height"] floatValue];
        self.originX = element[@"originX"];
        self.originY = element[@"originY"];
        if (element[@"transformMatrix"] != nil && [element[@"transformMatrix"] isKindOfClass:[NSArray class]] && [element[@"transformMatrix"] count] == 6) {
            CGFloat translateX = [element[@"transformMatrix"][4] floatValue];
            CGFloat translateY = [element[@"transformMatrix"][5] floatValue];
            frame.origin.x += translateX;
            frame.origin.y += translateY;
        }
        self.frame = frame;
    }
    self.opacity = [element[@"opacity"] floatValue];
    self.fill = [element[@"fill"] svg_color];
    self.fillRule = element[@"fillRule"];
    self.stroke = [element[@"stroke"] svg_color];
    self.strokeDashArray = element[@"strokeDashArray"];
    self.strokeLineCap = element[@"strokeLineCap"];
    self.strokeLineJoin = element[@"strokeLineJoin"];
    self.strokeMiterLimit = [element[@"strokeMiterLimit"] floatValue];
    self.strokeWidth = [element[@"strokeWidth"] floatValue];
}

- (MSLayer *)requestSketchLayer {
    return nil;
}

- (void)resetSketchProps:(MSLayer *)layer {
    layer.frame.x = self.frame.origin.x * self.scale;
    layer.frame.y = self.frame.origin.y * self.scale;
    layer.frame.width = self.frame.size.width * self.scale;
    layer.frame.height = self.frame.size.height * self.scale;
    if ([self.originX isEqualToString:@"center"]) {
        layer.frame.x -= layer.frame.width / 2.0;
    }
    else if ([self.originX isEqualToString:@"right"]) {
        layer.frame.x -= layer.frame.width;
    }
    if ([self.originY isEqualToString:@"center"]) {
        layer.frame.y -= layer.frame.height / 2.0;
    }
    else if ([self.originY isEqualToString:@"bottom"]) {
        layer.frame.y -= layer.frame.height;
    }
    if (self.styleGeneric != nil) {
        if (self.fill != nil) {
            [self.styleGeneric performSelector:@selector(enabledFills)];
            id msColor = [NSClassFromString(@"MSColor") new];
            NSColor *color = [NSColor hx_colorWithHexRGBAString:self.fill];
            [msColor setValue:@(color.redComponent) forKey:@"red"];
            [msColor setValue:@(color.greenComponent) forKey:@"green"];
            [msColor setValue:@(color.blueComponent) forKey:@"blue"];
            [msColor setValue:@(color.alphaComponent) forKey:@"alpha"];
            id fillStyle = [NSClassFromString(@"MSStyleFill") new];
            [fillStyle setValue:msColor forKey:@"color"];
            if ([self.fill isEqualToString:@"evenodd"]) {
                [layer setValue:@(1) forKey:@"windingRule"];
            }
            else {
                [layer setValue:@(0) forKey:@"windingRule"];
            }
            [self.styleGeneric setValue:fillStyle forKey:@"fill"];
        }
        if (self.stroke != nil) {
            [self.styleGeneric performSelector:@selector(enabledBorders)];
            id msColor = [NSClassFromString(@"MSColor") new];
            NSColor *color = [NSColor hx_colorWithHexRGBAString:self.stroke];
            [msColor setValue:@(color.redComponent) forKey:@"red"];
            [msColor setValue:@(color.greenComponent) forKey:@"green"];
            [msColor setValue:@(color.blueComponent) forKey:@"blue"];
            [msColor setValue:@(color.alphaComponent) forKey:@"alpha"];
            id borderStyle = [NSClassFromString(@"MSStyleBorder") new];
            [borderStyle setValue:msColor forKey:@"color"];
            [borderStyle setValue:@(self.strokeWidth * self.scale) forKey:@"thickness"];
            id msBorderOptions = [NSClassFromString(@"MSStyleBorderOptions") new];
            if (self.strokeDashArray != nil) {
                [msBorderOptions setValue:self.strokeDashArray forKey:@"dashPattern"];
            }
            if ([self.strokeLineCap isEqualToString:@"round"]) {
                [msBorderOptions setValue:@(1) forKey:@"lineCapStyle"];
            }
            else if ([self.strokeLineCap isEqualToString:@"square"]) {
                [msBorderOptions setValue:@(2) forKey:@"lineCapStyle"];
            }
            [self.styleGeneric setValue:borderStyle forKey:@"border"];
            [self.styleGeneric setValue:msBorderOptions forKey:@"borderOptions"];
        }
    }
}

@end

@implementation COMSVGCanvasEntity

- (void)parseWithElements:(NSArray *)elements options:(NSDictionary *)options {
    self.viewBox = CGSizeMake([options[@"width"] floatValue], [options[@"height"] floatValue]);
    NSMutableArray *items = [NSMutableArray array];
    [elements enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        COMSVGBaseEntity *item = [COMSVGBaseEntity parse:obj];
        if (item != nil) {
            [items addObject:item];
        }
    }];
    self.layers = [items copy];
}

- (void)exportToSketch:(CGFloat)toWidth {
    if (self.viewBox.width > 0) {
        self.scale = toWidth / self.viewBox.width;
    }
    if (self.scale == 0) {
        self.scale = 1.0;
    }
    MSDocument *document = Sketch_GetCurrentDocument();
    MSPage *currentPage = [document currentPage];
    MSArtboardGroup *artboard = [MSArtboardGroup_Class new];
    [currentPage addLayers:@[artboard]];
    artboard.name = @"SVG";
    artboard.frame.x = currentPage.scrollOrigin.x + 100.0;
    artboard.frame.y = currentPage.scrollOrigin.y + 100.0;
    artboard.frame.width = self.viewBox.width * self.scale;
    artboard.frame.height = self.viewBox.height * self.scale;
    [self.layers enumerateObjectsUsingBlock:^(COMSVGBaseEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setScale:self.scale];
        MSLayer *sketchLayer = [obj requestSketchLayer];
        if (sketchLayer != nil) {
            [artboard addLayers:@[sketchLayer]];
        }
    }];
}

@end

@implementation COMSVGTextEntity

+ (COMSVGBaseEntity *)parse:(NSDictionary *)element {
    COMSVGTextEntity *item = [COMSVGTextEntity new];
    [item parse:element];
    return item;
}

- (void)parse:(NSDictionary *)element {
    NSMutableDictionary *fixedElement = [element mutableCopy];
    fixedElement[@"originX"] = @"center";
    fixedElement[@"originY"] = @"center";
    element = fixedElement;
    [super parse:element];
    self.text = element[@"text"];
    self.textColor = self.fill;
    self.fontFamily = element[@"fontFamily"];
    self.fontSize = [element[@"fontSize"] floatValue];
    self.fontStyle = element[@"fontStyle"];
    self.fontWeight = [element[@"fontWeight"] floatValue];
    self.textAlignment = element[@"textAlign"];
}

- (MSLayer *)requestSketchLayer {
    MSTextLayer *textLayer = [MSTextLayer_Class new];
    self.styleGeneric = [textLayer valueForKey:@"styleGeneric"];
    [self resetSketchProps:textLayer];
    return textLayer;
}

- (void)resetSketchProps:(MSLayer *)layer {
    [super resetSketchProps:layer];
    [layer setValue:self.text forKey:@"stringValue"];
    [layer setValue:@(self.fontSize * self.scale) forKey:@"fontSize"];
    NSFont *font = [NSFont fontWithName:self.fontFamily size:self.fontSize * self.scale];
    if (font == nil) {
        CGFloat weight = NSFontWeightRegular;
        if (self.fontWeight >= 100 && self.fontWeight < 300) {
            weight = NSFontWeightUltraLight;
        }
        else if (self.fontWeight >= 300 && self.fontWeight < 400) {
            weight = NSFontWeightLight;
        }
        else if (self.fontWeight >= 400 && self.fontWeight < 500) {
            weight = NSFontWeightRegular;
        }
        else if (self.fontWeight >= 500 && self.fontWeight < 600) {
            weight = NSFontWeightMedium;
        }
        else if (self.fontWeight >= 600 && self.fontWeight < 700) {
            weight = NSFontWeightSemibold;
        }
        else if (self.fontWeight >= 700 && self.fontWeight < 800) {
            weight = NSFontWeightBold;
        }
        else if (self.fontWeight >= 800 && self.fontWeight < 900) {
            weight = NSFontWeightHeavy;
        }
        else if (self.fontWeight >= 900 && self.fontWeight < 1000) {
            weight = NSFontWeightBlack;
        }
        font = [NSFont systemFontOfSize:self.fontSize * self.scale weight:weight];
    }
    [layer setValue:font forKey:@"font"];
    if ([self.textAlignment isEqualToString:@"center"]) {
        [layer setValue:@(NSTextAlignmentCenter) forKey:@"textAlignment"];
    }
    else if ([self.textAlignment isEqualToString:@"right"]) {
        [layer setValue:@(NSTextAlignmentRight) forKey:@"textAlignment"];
    }
    id msColor = [NSClassFromString(@"MSColor") new];
    NSColor *color = [NSColor hx_colorWithHexRGBAString:self.textColor];
    [msColor setValue:@(color.redComponent) forKey:@"red"];
    [msColor setValue:@(color.greenComponent) forKey:@"green"];
    [msColor setValue:@(color.blueComponent) forKey:@"blue"];
    [msColor setValue:@(color.alphaComponent) forKey:@"alpha"];
    [layer setValue:msColor forKey:@"textColor"];
    if (self.scale < 1.0) {
        CGFloat _scale = self.scale;
        self.scale = 1.0;
        MSLayer *originLayer = [self requestSketchLayer];
        CGFloat heightOffset = originLayer.frame.height * _scale - layer.frame.height;
        layer.frame.y += heightOffset;
        self.scale = _scale;
    }
}

@end

@implementation COMSVGImageEntity

+ (COMSVGBaseEntity *)parse:(NSDictionary *)element {
    COMSVGImageEntity *item = [COMSVGImageEntity new];
    [item parse:element];
    return item;
}

- (void)parse:(NSDictionary *)element {
    [super parse:element];
    {
        if (element[@"src"] != nil) {
            NSString *base64String = [element[@"src"] stringByReplacingOccurrencesOfString:@"data:img/png;base64," withString:@""];
            NSData *base64Data = [[NSData alloc] initWithBase64EncodedString:base64String options:kNilOptions];
            if (base64Data != nil) {
                self.image = [[NSImage alloc] initWithData:base64Data];
            }
        }
    }
}

- (MSLayer *)requestSketchLayer {
    MSLayer *bitmapLayer = [NSClassFromString(@"MSBitmapLayer") new];
    [self resetSketchProps:bitmapLayer];
    return bitmapLayer;
}

- (void)resetSketchProps:(MSLayer *)layer {
    [super resetSketchProps:layer];
    id imageData = [NSClassFromString(@"MSImageData") new];
    [imageData setValue:self.image forKey:@"image"];
    [layer setValue:imageData forKey:@"image"];
}

@end

@implementation COMSVGPathEntity

+ (COMSVGBaseEntity *)parse:(NSDictionary *)element {
    COMSVGPathEntity *item = [COMSVGPathEntity new];
    [item parse:element];
    return item;
}

- (void)parse:(NSDictionary *)element {
    [super parse:element];
    if ([element[@"path"] isKindOfClass:[NSArray class]]) {
        NSMutableString *d = [NSMutableString string];
        [element[@"path"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSArray class]]) {
                [d appendString:[obj componentsJoinedByString:@" "]];
            }
        }];
        if ([d containsString:@"a"] || [d containsString:@"A"]) {
            NSString *tmpXML = [NSString stringWithFormat:@"<svg xmlns=\"http://www.w3.org/2000/svg\"><path d=\"%@\" /></svg>", [d copy]];
            SVGKImage *tmpImage = [[SVGKImage alloc] initWithData:[tmpXML dataUsingEncoding:NSUTF8StringEncoding]];
            if ([[tmpImage.CALayerTree.sublayers firstObject] isKindOfClass:[CAShapeLayerWithHitTest class]]) {
                CAShapeLayerWithHitTest *layer = (id)[tmpImage.CALayerTree.sublayers firstObject];
                NSBezierPath *path = [NSBezierPath bezierPath];
                CGPathApply(layer.path, (__bridge void *)path, sPathApplier);
                self.bezierPath = path;
            }
        }
        else {
            self.bezierPath = [NSBezierPath bezierPathWithSVGString:d];
        }
    }
}

- (MSLayer *)requestSketchLayer {
    NSBezierPath *scaledPath = [self.bezierPath copy];
    NSAffineTransform *transform = [NSAffineTransform new];
    [transform scaleBy:self.scale];
    [scaledPath transformUsingAffineTransform:transform];
    MSShapeGroup *shapeGroup = [MSShapeGroup_Class shapeWithBezierPath:scaledPath];
    self.styleGeneric = [shapeGroup valueForKey:@"styleGeneric"];
    [self resetSketchProps:shapeGroup];
    return shapeGroup;
}

- (void)resetSketchProps:(MSLayer *)layer {
    [super resetSketchProps:layer];
}

@end

@implementation COMSVGCircleEntity

+ (COMSVGBaseEntity *)parse:(NSDictionary *)element {
    COMSVGCircleEntity *item = [COMSVGCircleEntity new];
    [item parse:element];
    return item;
}

- (void)parse:(NSDictionary *)element {
    [super parse:element];
    CGFloat width = [element[@"width"] floatValue] * self.scale;
    CGFloat height = [element[@"height"] floatValue] * self.scale;
    CGFloat radius = [element[@"radius"] floatValue] * self.scale;
    self.bezierPath = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, 0, width, height) xRadius:radius yRadius:radius];
}

@end

@implementation NSString (SVGColor)

- (NSString *)svg_color {
    if ([self hasPrefix:@"rgb"]) {
        NSString *formated = [[self stringByReplacingOccurrencesOfString:@"rgb(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""];
        NSArray *coms = [formated componentsSeparatedByString:@","];
        if (coms.count == 3) {
            int r = [coms[0] intValue];
            int g = [coms[1] intValue];
            int b = [coms[2] intValue];
            return [NSString stringWithFormat:@"#%02x%02x%02x", r, g, b];
        }
    }
    if ([self isEqualToString:@"black"]) {
        return @"#000000";
    }
    else if ([self isEqualToString:@"green"]) {
        return @"#008000";
    }
    else if ([self isEqualToString:@"silver"]) {
        return @"#C0C0C0";
    }
    else if ([self isEqualToString:@"lime"]) {
        return @"#00FF00";
    }
    else if ([self isEqualToString:@"gray"]) {
        return @"#808080";
    }
    else if ([self isEqualToString:@"olive"]) {
        return @"#808000";
    }
    else if ([self isEqualToString:@"white"]) {
        return @"#FFFFFF";
    }
    else if ([self isEqualToString:@"yellow"]) {
        return @"#FFFF00";
    }
    else if ([self isEqualToString:@"maroon"]) {
        return @"#800000";
    }
    else if ([self isEqualToString:@"navy"]) {
        return @"#000080";
    }
    else if ([self isEqualToString:@"red"]) {
        return @"#FF0000";
    }
    else if ([self isEqualToString:@"blue"]) {
        return @"#0000FF";
    }
    else if ([self isEqualToString:@"purple"]) {
        return @"#800080";
    }
    else if ([self isEqualToString:@"teal"]) {
        return @"#008080";
    }
    else if ([self isEqualToString:@"fuchsia"]) {
        return @"#FF00FF";
    }
    else if ([self isEqualToString:@"aqua"]) {
        return @"#00FFFF";
    }
    return self;
}

@end
