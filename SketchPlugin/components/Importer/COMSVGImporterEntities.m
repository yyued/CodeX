//
//  COMSVGImporterEntities.m
//  components
//
//  Created by 崔明辉 on 2017/1/5.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "COMSVGImporterEntities.h"
#import <MCSketchPluginFramework/MCSketchPluginFramework.h>

@implementation COMSVGBaseEntity

+ (COMSVGBaseEntity *)parse:(NSDictionary *)element {
    if ([element[@"type"] isEqualToString:@"image"]) {
        return [COMSVGImageEntity parse:element];
    }
    else if ([element[@"type"] isEqualToString:@"text"]) {
        return [COMSVGTextEntity parse:element];
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
        if ([element[@"originX"] isEqualToString:@"center"]) {
            frame.origin.x -= frame.size.width / 2.0;
        }
        else if ([element[@"originX"] isEqualToString:@"right"]) {
            frame.origin.x -= frame.size.width;
        }
        if ([element[@"originY"] isEqualToString:@"center"]) {
            frame.origin.y -= frame.size.height / 2.0;
        }
        else if ([element[@"originY"] isEqualToString:@"bottom"]) {
            frame.origin.y -= frame.size.height;
        }
        self.frame = frame;
    }
    self.opacity = [element[@"opacity"] floatValue];
    self.fill = element[@"fill"];
    self.fillRule = element[@"fillRule"];
}

- (MSLayer *)requestSketchLayer {
    return nil;
}

- (void)resetSketchProps:(MSLayer *)layer {
    layer.frame.x = self.frame.origin.x;
    layer.frame.y = self.frame.origin.y;
    layer.frame.width = self.frame.size.width;
    layer.frame.height = self.frame.size.height;
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

- (void)exportToSketch {
    MSDocument *document = Sketch_GetCurrentDocument();
    MSPage *currentPage = [document currentPage];
    MSArtboardGroup *artboard = [MSArtboardGroup_Class new];
    [currentPage addLayers:@[artboard]];
    artboard.name = @"SVG~~~";
    artboard.frame.x = currentPage.scrollOrigin.x + 100.0;
    artboard.frame.y = currentPage.scrollOrigin.y + 100.0;
    artboard.frame.width = self.viewBox.width;
    artboard.frame.height = self.viewBox.height;
    [self.layers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
    [self resetSketchProps:textLayer];
    return textLayer;
}

- (void)resetSketchProps:(MSLayer *)layer {
    [super resetSketchProps:layer];
    [layer setValue:self.text forKey:@"stringValue"];
    [layer setValue:@(self.fontSize) forKey:@"fontSize"];
    NSFont *font = [NSFont fontWithName:self.fontFamily size:self.fontSize];
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
        font = [NSFont systemFontOfSize:self.fontSize weight:weight];
    }
    [layer setValue:font forKey:@"font"];
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
