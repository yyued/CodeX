//
//  COMGenerator.m
//  components
//
//  Created by 崔明辉 on 2016/12/9.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMGenerator.h"
#import "COMAssetsWriter.h"
#import <WebKit/WebKit.h>

@interface COMGenerator ()

@property(nonatomic, strong) NSString *xmlString;
@property(nonatomic, strong) NSDictionary *spec;

@end

@implementation COMGenerator

static JSContext *context;
static WebView *webView;

+ (JSContext *)context {
    return context;
}

- (void)loadLibrary {
    webView = [WebView new];
    context = webView.mainFrame.javaScriptContext;
    context[@"spec"] = ^(NSString *uuid) {
      return self.spec[uuid];
    };
    context[@"oc_writeAssets"] = ^(NSString *base64String, CGFloat baseWidth, CGFloat baseHeight, NSString *fileName) {
      NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:kNilOptions];
      if (data != nil) {
          NSImage *image = [[NSImage alloc] initWithData:data];
          if (image != nil) {
              [COMAssetsWriter writeIOSImage:image
                                     baseSize:CGSizeMake(baseWidth, baseHeight)
                                 toAssetsPath:self.assetsPath
                                     fileName:fileName];
          }
      }
    };
    for (NSString *dirName in [[NSFileManager defaultManager] enumeratorAtPath:self.libraryPath]) {
        NSString *subPath = [self.libraryPath stringByAppendingFormat:@"/%@", dirName];
        for (NSString *fileName in [[NSFileManager defaultManager] enumeratorAtPath:subPath]) {
            if ([fileName hasSuffix:@".js"]) {
                NSString *filePath = [subPath stringByAppendingFormat:@"/%@", fileName];
                NSString *fileContents =
                    [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
                if (fileContents != nil) {
                    [context evaluateScript:fileContents];
                }
            }
        }
    }
}

- (COMGenLayer *)parse {
    [self loadLibrary];
    self.xmlString = [NSString stringWithContentsOfFile:@"/tmp/com.yy.ued.sketch.components/tmp.svg"
                                               encoding:NSUTF8StringEncoding
                                                  error:NULL];
    NSString *unsupportedXMLString = self.xmlString;
    unsupportedXMLString =
        [unsupportedXMLString stringByReplacingOccurrencesOfString:@"<pattern " withString:@"<!--<pattern "];
    unsupportedXMLString =
        [unsupportedXMLString stringByReplacingOccurrencesOfString:@"</pattern>" withString:@"</pattern>-->"];
    self.spec = [NSJSONSerialization
        JSONObjectWithData:[NSData dataWithContentsOfFile:@"/tmp/com.yy.ued.sketch.components/tmp.json"]
                   options:kNilOptions
                     error:NULL];
    SVGKImage *image = [SVGKImage imageWithData:[unsupportedXMLString dataUsingEncoding:NSUTF8StringEncoding]];
    COMGenLayer *rootLayer = [COMGenLayer new];
    rootLayer.layerClass = @"UIView";
    rootLayer.props = @{
        @"class" : @"UIView",
        @"outletID" : @"rootView",
    };
    [self parseLayer:rootLayer element:image.DOMDocument.rootElement];
    COMGenLayer *deeperRootLayer = [self findRootLayer:rootLayer.sublayers];
    return deeperRootLayer != nil ? deeperRootLayer : rootLayer;
}

- (COMGenLayer *)findRootLayer:(NSArray<COMGenLayer *> *)sublayers {
    for (COMGenLayer *sublayer in sublayers) {
        if ([sublayer.props[@"outletID"] isKindOfClass:[NSString class]] &&
            [sublayer.props[@"outletID"] isEqualToString:@"rootView"]) {
            return sublayer;
        } else {
            COMGenLayer *deeper = [self findRootLayer:[sublayer sublayers]];
            if (deeper != nil) {
                return deeper;
            }
        }
    }
    return nil;
}

- (void)parseLayer:(COMGenLayer *)layer element:(SVGKNode *)element {
    for (int i = 0; i < element.childNodes.length; i++) {
        SVGKNode *node = [element.childNodes item:i];
        NSString *nodeID = [[node.attributes getNamedItem:@"id"] nodeValue];
        NSString *nodeClass = self.spec[nodeID][@"class"];
        if ([nodeID isKindOfClass:[NSString class]] && [nodeClass isKindOfClass:[NSString class]] &&
            self.spec[nodeID] != nil && context[nodeClass] != nil) {
            COMGenLayer *sublayer = [COMGenLayer new];
            sublayer.layerID = nodeID;
            sublayer.layerClass = self.spec[nodeID][@"class"];
            sublayer.props = [[context[nodeClass][@"parse"]
                callWithArguments:@[ nodeID, self.xmlString, self.spec[nodeID] ]] toDictionary];
            [self parseLayer:sublayer element:node];
            layer.sublayers = [layer.sublayers arrayByAddingObject:sublayer];
        } else {
            [self parseLayer:layer element:node];
        }
    }
}





@end
