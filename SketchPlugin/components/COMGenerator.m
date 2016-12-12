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

@interface COMGenerator ()

@property(nonatomic, strong) NSString *xmlString;
@property(nonatomic, strong) NSDictionary *spec;

@end

@implementation COMGenerator

static JSContext *context;
static WebView *webView;

- (void)loadLibrary {
    webView = [WebView new];
    context = webView.mainFrame.javaScriptContext;
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
    self.spec = [NSJSONSerialization
        JSONObjectWithData:[NSData dataWithContentsOfFile:@"/tmp/com.yy.ued.sketch.components/tmp.json"]
                   options:kNilOptions
                     error:NULL];
    SVGKImage *image = [SVGKImage imageWithData:[self.xmlString dataUsingEncoding:NSUTF8StringEncoding]];
    COMGenLayer *rootLayer = [COMGenLayer new];
    rootLayer.layerClass = @"UIView";
    rootLayer.props = @{
        @"class" : @"UIView",
        @"outlet" : @"rootView",
        @"tag" : @(999999999),
    };
    [self parseLayer:rootLayer element:image.DOMDocument.rootElement];
    return rootLayer;
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

- (NSDictionary *)oc_code:(COMGenLayer *)layer genType:(COMGenType)genType {
    NSString *superClass = genType == COMGenTypeViewController ? @"UIViewController" : @"UIView";
    NSMutableString *headerCode = [[NSMutableString alloc]
        initWithFormat:@"//\n//  %@.h\n//  %@\n//\n//  Created by CodeX on %@.\n\n#import <UIKit/UIKit.h>\n#import "
                       @"\"COXRuntime.h\"\n\n@interface %@ : %@\n\n",
                       self.className, self.className, [NSDate date], self.className, superClass];
    NSMutableString *implementationCode = [[NSMutableString alloc]
        initWithFormat:
            @"//\n//  %@.h\n//  %@\n//\n//  Created by CodeX on %@.\n\n#import \"%@.h\"\n\n@implementation %@\n\n",
            self.className, self.className, [NSDate date], self.className, self.className];
    if (genType == COMGenTypeViewController) {
        [implementationCode appendString:@"- (void)loadView {\n"];
        [implementationCode appendString:@"    self.view = [self rootView];\n"];
        [implementationCode appendString:@"    self.view.backgroundColor = [UIColor whiteColor];\n"];
        [implementationCode appendString:@"}\n\n"];
    }
    else if (genType == COMGenTypeView) {
        [implementationCode appendString:@"- (void)willMoveToSuperview:(UIView *)newSuperview {\n"];
        [implementationCode appendString:@"    [super willMoveToSuperview:newSuperview];\n"];
        [implementationCode appendString:@"    UIView *rootView = self.rootView;\n"];
        [implementationCode appendString:@"    rootView.frame = self.bounds;\n"];
        [implementationCode appendString:@"    rootView.autoresizingMask = UIViewAutoresizingFlexibleWidth | "
                                         @"UIViewAutoresizingFlexibleHeight;\n"];
        [implementationCode appendString:@"    [self addSubview:rootView];\n"];
        [implementationCode appendString:@"}\n\n"];
    }
    [self oc_code:layer headerCode:headerCode implementationCode:implementationCode];
    [headerCode appendString:@"\n@end\n"];
    [implementationCode appendString:@"@end\n"];
    return @{
        [NSString stringWithFormat:@"%@.h", self.className] : [headerCode copy],
        [NSString stringWithFormat:@"%@.m", self.className] : [implementationCode copy],
    };
}

- (void)oc_code:(COMGenLayer *)layer
            headerCode:(NSMutableString *)headerCode
    implementationCode:(NSMutableString *)implementationCode {
    NSString *outlet = layer.props[@"outlet"];
    NSString *ocClass = [[context[layer.layerClass][@"oc_class"] callWithArguments:@[ layer.props ]] toString];
    if ([ocClass isEqualToString:@"undefined"]) {
        return;
    }
    if (outlet != nil && outlet.length) {
        [headerCode appendFormat:@"@property (nonatomic, strong) %@ *%@;\n", ocClass, outlet];
        NSMutableString *mCode = [NSMutableString new];
        [mCode appendFormat:@"- (%@ *)%@ {\n", ocClass, outlet];
        [mCode appendFormat:@"    if (_%@ == nil) {\n", outlet];
        NSString *mmCode = [[context[layer.layerClass][@"oc_code"] callWithArguments:@[ layer.props ]] toString];
        if (mmCode != nil) {
            [[mmCode componentsSeparatedByString:@"\n"]
                enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                  if (!obj.length) {
                      return;
                  }
                  [mCode appendString:[NSString stringWithFormat:@"        %@\n", obj]];
                }];
            for (COMGenLayer *sublayer in layer.sublayers) {
                NSString *ocClass = [[context[sublayer.layerClass][@"oc_class"] callWithArguments:@[ sublayer.props ]] toString];
                if ([ocClass isEqualToString:@"undefined"]) {
                    continue;
                }
                NSString *sublayerOutlet = sublayer.props[@"outlet"];
                if (sublayerOutlet != nil && sublayerOutlet.length) {
                    [mCode appendFormat:@"        [view addSubview:self.%@];\n", sublayerOutlet];
                } else {
                    [mCode appendFormat:@"        [view addSubview:[self _%@]];\n",
                                        [sublayer.layerID stringByReplacingOccurrencesOfString:@"-" withString:@"_"]];
                }
            }
            [mCode appendFormat:@"        _%@ = view;\n", outlet];
        }
        [mCode appendFormat:@"    }\n"];
        [mCode appendFormat:@"    return _%@;\n", outlet];
        [mCode appendFormat:@"}\n\n"];
        [implementationCode appendString:mCode];
    }
    else {
        NSMutableString *mCode = [NSMutableString new];
        [mCode appendFormat:@"- (%@ *)_%@ {\n", ocClass,
                            [layer.layerID stringByReplacingOccurrencesOfString:@"-" withString:@"_"]];
        NSString *mmCode = [[context[layer.layerClass][@"oc_code"] callWithArguments:@[ layer.props ]] toString];
        if (mmCode != nil) {
            [[mmCode componentsSeparatedByString:@"\n"]
                enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                  if (!obj.length) {
                      return;
                  }
                  [mCode appendString:[NSString stringWithFormat:@"    %@\n", obj]];
                }];
            for (COMGenLayer *sublayer in layer.sublayers) {
                NSString *ocClass = [[context[sublayer.layerClass][@"oc_class"] callWithArguments:@[ sublayer.props ]] toString];
                if ([ocClass isEqualToString:@"undefined"]) {
                    continue;
                }
                NSString *sublayerOutlet = sublayer.props[@"outlet"];
                if (sublayerOutlet != nil && sublayerOutlet.length) {
                    [mCode appendFormat:@"    [view addSubview:self.%@];\n", sublayerOutlet];
                } else {
                    [mCode appendFormat:@"    [view addSubview:[self _%@]];\n",
                                        [sublayer.layerID stringByReplacingOccurrencesOfString:@"-" withString:@"_"]];
                }
            }
            [mCode appendString:@"    return view;\n"];
        } else {
            [mCode appendString:@"    return nil;\n"];
        }
        [mCode appendFormat:@"}\n\n"];
        [implementationCode appendString:mCode];
    }
    for (COMGenLayer *sublayer in layer.sublayers) {
        [self oc_code:sublayer headerCode:headerCode implementationCode:implementationCode];
    }
}

@end
