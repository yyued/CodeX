//
//  COMGenerator.m
//  components
//
//  Created by 崔明辉 on 2016/12/9.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMGenerator.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <WebKit/WebKit.h>

static NSString *libraryPath = @"/Users/cuiminghui/Documents/Works/OpenSource/CodeX/Library";

@interface COMGenerator ()

@property (nonatomic, strong) NSString *xmlString;
@property (nonatomic, strong) NSDictionary *spec;

@end

@implementation COMGenerator

static JSContext *context;
static WebView *webView;

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        webView = [WebView new];
        context = webView.mainFrame.javaScriptContext;
        for (NSString *dirName in [[NSFileManager defaultManager] enumeratorAtPath:libraryPath]) {
            NSString *subPath = [libraryPath stringByAppendingFormat:@"/%@", dirName];
            for (NSString *fileName in [[NSFileManager defaultManager] enumeratorAtPath:subPath]) {
                if ([fileName hasSuffix:@".js"]) {
                    NSString *filePath = [subPath stringByAppendingFormat:@"/%@", fileName];
                    NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
                    if (fileContents != nil) {
                        [context evaluateScript:fileContents];
                    }
                }
            }
        }
    });
}

- (COMGenLayer *)parse {
    self.xmlString = [NSString stringWithContentsOfFile:@"/tmp/com.yy.ued.sketch.components/tmp.svg" encoding:NSUTF8StringEncoding error:NULL];
    self.spec = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:@"/tmp/com.yy.ued.sketch.components/tmp.json"] options:kNilOptions error:NULL];
    SVGKImage *image = [SVGKImage imageWithData:[self.xmlString dataUsingEncoding:NSUTF8StringEncoding]];
    COMGenLayer *rootLayer = [COMGenLayer new];
    [self parseLayer:rootLayer element:image.DOMDocument.rootElement];
    return rootLayer;
}

- (void)parseLayer:(COMGenLayer *)layer element:(SVGKNode *)element {
    for (int i = 0; i < element.childNodes.length; i++) {
        SVGKNode *node = [element.childNodes item:i];
        NSString *nodeID = [[node.attributes getNamedItem:@"id"] nodeValue];
        NSString *nodeClass = self.spec[nodeID][@"class"];
        if ([nodeID isKindOfClass:[NSString class]] && [nodeClass isKindOfClass:[NSString class]] && self.spec[nodeID] != nil && context[nodeClass] != nil) {
            COMGenLayer *sublayer = [COMGenLayer new];
            sublayer.layerID = nodeID;
            sublayer.layerClass = self.spec[nodeID][@"class"];
            sublayer.props = [[context[nodeClass][@"parse"] callWithArguments:@[nodeID, self.xmlString, self.spec[nodeID]]] toDictionary];
            [self parseLayer:sublayer element:node];
            layer.sublayers = [layer.sublayers arrayByAddingObject:sublayer];
        }
        else {
            [self parseLayer:layer element:node];
        }
    }
}

@end
