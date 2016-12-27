//
//  COMGenerator.m
//  components
//
//  Created by 崔明辉 on 2016/12/9.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMGenerator.h"
#import "COMAssetsWritter.h"
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
    context[@"spec"] = ^(NSString *uuid) {
      return self.spec[uuid];
    };
    context[@"oc_writeAssets"] = ^(NSString *base64String, CGFloat baseWidth, CGFloat baseHeight, NSString *fileName) {
      NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:kNilOptions];
      if (data != nil) {
          NSImage *image = [[NSImage alloc] initWithData:data];
          if (image != nil) {
              [COMAssetsWritter writeIOSImage:image
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
    NSMutableString *loadCode = [[NSMutableString alloc] initWithString:@""];
    NSMutableString *viewDidLoadCode = [[NSMutableString alloc] initWithString:@""];
    if (genType == COMGenTypeViewController) {
        [implementationCode appendString:@"- (void)loadView {\n"];
        [implementationCode appendString:@"    self.view = [self rootView];\n"];
        [implementationCode appendString:@"    self.view.backgroundColor = [UIColor whiteColor];\n"];
        [implementationCode appendString:@"}\n\n"];
    } else if (genType == COMGenTypeView) {
        [implementationCode appendString:@"- (void)willMoveToSuperview:(UIView *)newSuperview {\n"];
        [implementationCode appendString:@"    [super willMoveToSuperview:newSuperview];\n"];
        [implementationCode appendString:@"    UIView *rootView = self.rootView;\n"];
        [implementationCode appendString:@"    rootView.frame = self.bounds;\n"];
        [implementationCode appendString:@"    rootView.autoresizingMask = UIViewAutoresizingFlexibleWidth | "
                                         @"UIViewAutoresizingFlexibleHeight;\n"];
        [implementationCode appendString:@"    [self addSubview:rootView];\n"];
        [implementationCode appendString:@"}\n\n"];
    }
    [self oc_code:layer
                headerCode:headerCode
        implementationCode:implementationCode
                  loadCode:loadCode
           viewDidLoadCode:viewDidLoadCode];

    if (genType == COMGenTypeViewController && loadCode.length) {
        [implementationCode appendFormat:@"\n+ (void)load {\n%@}\n\n", loadCode];
    }
    if (genType == COMGenTypeViewController && viewDidLoadCode.length) {
        [implementationCode
            appendFormat:@"\n- (void)viewDidLoad {\n    [super viewDidLoad];\n%@}\n\n", viewDidLoadCode];
    }
    [headerCode appendString:@"\n@end\n"];
    [implementationCode appendString:@"@end\n"];
    return @{
        [NSString stringWithFormat:@"%@.h", self.className] : [headerCode copy],
        [NSString stringWithFormat:@"%@.m", self.className] : [implementationCode copy],
    };
}

- (void)oc_code:(COMGenLayer *)layer
            headerCode:(NSMutableString *)headerCode
    implementationCode:(NSMutableString *)implementationCode
              loadCode:(NSMutableString *)loadCode
       viewDidLoadCode:(NSMutableString *)viewDidLoadCode {
    NSString *outlet = layer.props[@"outletID"];
    {
        NSString *_loadCode = [[context[layer.layerClass][@"oc_load"] callWithArguments:@[ layer.props ]] toString];
        if (_loadCode != nil && _loadCode.length && ![_loadCode isEqualToString:@"undefined"]) {
            [[_loadCode componentsSeparatedByString:@"\n"]
                enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                  if (!obj.length) {
                      return;
                  }
                  [loadCode appendString:[NSString stringWithFormat:@"    %@\n", obj]];
                }];
        }
    }
    {
        NSString *_viewDidLoadCode =
            [[context[layer.layerClass][@"oc_viewDidLoad"] callWithArguments:@[ layer.props ]] toString];
        if (_viewDidLoadCode != nil && _viewDidLoadCode.length && ![_viewDidLoadCode isEqualToString:@"undefined"]) {
            [[_viewDidLoadCode componentsSeparatedByString:@"\n"]
                enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                  if (!obj.length) {
                      return;
                  }
                  [viewDidLoadCode appendString:[NSString stringWithFormat:@"    %@\n", obj]];
                }];
        }
    }
    NSString *ocClass = [[context[layer.layerClass][@"oc_class"] callWithArguments:@[ layer.props ]] toString];
    if ([ocClass isEqualToString:@"undefined"]) {
        return;
    }
    if (outlet != nil && outlet.length) {
        [headerCode appendFormat:@"@property (nonatomic, strong) %@ *%@;\n", ocClass, outlet];
        NSMutableString *mCode = [NSMutableString new];
        NSString *mmCode = [[context[layer.layerClass][@"oc_code"] callWithArguments:@[ layer.props ]] toString];
        if (mmCode != nil && mmCode.length > 0 && ![mmCode isEqualToString:@"undefined"]) {
            [mCode appendFormat:@"- (%@ *)%@ {\n", ocClass, outlet];
            [mCode appendFormat:@"    if (_%@ == nil) {\n", outlet];
            [[mmCode componentsSeparatedByString:@"\n"]
                enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                  if (!obj.length) {
                      return;
                  }
                  [mCode appendString:[NSString stringWithFormat:@"        %@\n", obj]];
                }];
            for (COMGenLayer *sublayer in layer.sublayers) {
                NSString *ocClass =
                    [[context[sublayer.layerClass][@"oc_class"] callWithArguments:@[ sublayer.props ]] toString];
                if (ocClass == nil || !ocClass.length || [ocClass isEqualToString:@"undefined"]) {
                    continue;
                }
                NSString *sublayerOutlet = sublayer.props[@"outletID"];
                if (sublayerOutlet != nil && sublayerOutlet.length) {
                    [mCode appendFormat:@"        [view addSubview:self.%@];\n", sublayerOutlet];
                } else {
                    [mCode appendFormat:@"        [view addSubview:[self _%@]];\n",
                                        [sublayer.layerID stringByReplacingOccurrencesOfString:@"-" withString:@"_"]];
                }
            }
            [mCode appendFormat:@"        _%@ = view;\n", outlet];
            [mCode appendFormat:@"    }\n"];
            [mCode appendFormat:@"    return _%@;\n", outlet];
            [mCode appendFormat:@"}\n\n"];
        }
        [implementationCode appendString:mCode];
    } else {
        NSMutableString *mCode = [NSMutableString new];
        NSString *mmCode = [[context[layer.layerClass][@"oc_code"] callWithArguments:@[ layer.props ]] toString];
        if (mmCode != nil && mmCode.length > 0 && ![mmCode isEqualToString:@"undefined"]) {
            [mCode appendFormat:@"- (%@ *)_%@ {\n", ocClass,
                                [layer.layerID stringByReplacingOccurrencesOfString:@"-" withString:@"_"]];
            [[mmCode componentsSeparatedByString:@"\n"]
                enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                  if (!obj.length) {
                      return;
                  }
                  [mCode appendString:[NSString stringWithFormat:@"    %@\n", obj]];
                }];
            for (COMGenLayer *sublayer in layer.sublayers) {
                NSString *ocClass =
                    [[context[sublayer.layerClass][@"oc_class"] callWithArguments:@[ sublayer.props ]] toString];
                if (ocClass == nil || !ocClass.length || [ocClass isEqualToString:@"undefined"]) {
                    continue;
                }
                NSString *sublayerOutlet = sublayer.props[@"outletID"];
                if (sublayerOutlet != nil && sublayerOutlet.length) {
                    [mCode appendFormat:@"    [view addSubview:self.%@];\n", sublayerOutlet];
                } else {
                    [mCode appendFormat:@"    [view addSubview:[self _%@]];\n",
                                        [sublayer.layerID stringByReplacingOccurrencesOfString:@"-" withString:@"_"]];
                }
            }
            [mCode appendString:@"    return view;\n"];
            [mCode appendFormat:@"}\n\n"];
        }
        [implementationCode appendString:mCode];
    }
    for (COMGenLayer *sublayer in layer.sublayers) {
        [self oc_code:sublayer
                    headerCode:headerCode
            implementationCode:implementationCode
                      loadCode:loadCode
               viewDidLoadCode:viewDidLoadCode];
    }
}

- (NSXMLDocument *)xib_code:(COMGenLayer *)layer genType:(COMGenType)genType {
    NSXMLDocument *document = [NSXMLDocument document];
    NSXMLElement *rootElement = [NSXMLElement elementWithName:@"document"];
    [rootElement setAttributesAsDictionary:@{
        @"type" : @"com.apple.InterfaceBuilder3.CocoaTouch.XIB",
        @"version" : @"3.0",
        @"toolsVersion" : @"11762",
        @"systemVersion" : @"16C67",
        @"targetRuntime" : @"iOS.CocoaTouch",
        @"propertyAccessControl" : @"none",
        @"useAutolayout" : @"YES",
        @"useTraitCollections" : @"YES",
        @"colorMatched" : @"YES",
    }];
    {
        NSXMLElement *deviceElement = [NSXMLElement elementWithName:@"device"];
        {
            NSXMLElement *adaptation = [NSXMLElement elementWithName:@"adaptation"];
            [adaptation setAttributesAsDictionary:@{
                @"id" : @"fullscreen",
            }];
            [deviceElement addChild:adaptation];
        }
        [deviceElement setAttributesAsDictionary:@{
            @"id" : @"retina4_7",
            @"orientation" : @"portrait",
        }];
        [rootElement addChild:deviceElement];
    }
    {
        NSXMLElement *dependenciesElement = [NSXMLElement elementWithName:@"dependencies"];
        {
            NSXMLElement *deployment = [NSXMLElement elementWithName:@"deployment"];
            [deployment setAttributesAsDictionary:@{
                @"identifier" : @"iOS",
            }];
            [dependenciesElement addChild:deployment];
        }
        {
            NSXMLElement *plugIn = [NSXMLElement elementWithName:@"plugIn"];
            [plugIn setAttributesAsDictionary:@{
                @"identifier" : @"com.apple.InterfaceBuilder.IBCocoaTouchPlugin",
                @"version" : @"11757",
            }];
            [dependenciesElement addChild:plugIn];
        }
        {
            NSXMLElement *capability = [NSXMLElement elementWithName:@"capability"];
            [capability setAttributesAsDictionary:@{
                @"name" : @"documents saved in the Xcode 8 format",
                @"minToolsVersion" : @"8.0",
            }];
            [dependenciesElement addChild:capability];
        }
        [rootElement addChild:dependenciesElement];
    }
    {
        NSXMLElement *objects = [NSXMLElement elementWithName:@"objects"];
        {
            NSXMLElement *placeholder = [NSXMLElement elementWithName:@"placeholder"];
            [placeholder setAttributesAsDictionary:@{
                @"placeholderIdentifier" : @"IBFilesOwner",
                @"id" : @"-1",
                @"userLabel" : @"File's Owner",
                @"customClass" : self.className,
            }];
            {
                NSXMLElement *connections = [NSXMLElement elementWithName:@"connections"];
                {
                    NSXMLElement *outlet = [NSXMLElement elementWithName:@"outlet"];
                    [outlet setAttributesAsDictionary:@{
                        @"property" : @"view",
                        @"destination" : layer.layerID,
                        @"id" : [[NSUUID UUID] UUIDString],
                    }];
                    [connections addChild:outlet];
                }
                [placeholder addChild:connections];
            }
            {
                NSNumber *adjustInsets = [self xib_automaticallyAdjustsScrollViewInsets:layer];
                if (adjustInsets != nil && [adjustInsets boolValue]) {
                    NSXMLElement *element = [NSXMLElement elementWithName:@"userDefinedRuntimeAttributes"];
                    NSXMLElement *sElement = [NSXMLElement elementWithName:@"userDefinedRuntimeAttribute"];
                    [sElement setAttributesAsDictionary:@{
                        @"type" : @"boolean",
                        @"keyPath" : @"automaticallyAdjustsScrollViewInsets",
                        @"value" : @"YES",
                    }];
                    [element addChild:sElement];
                    [placeholder addChild:element];
                } else {
                    NSXMLElement *element = [NSXMLElement elementWithName:@"userDefinedRuntimeAttributes"];
                    NSXMLElement *sElement = [NSXMLElement elementWithName:@"userDefinedRuntimeAttribute"];
                    [sElement setAttributesAsDictionary:@{
                        @"type" : @"boolean",
                        @"keyPath" : @"automaticallyAdjustsScrollViewInsets",
                        @"value" : @"NO",
                    }];
                    [element addChild:sElement];
                    [placeholder addChild:element];
                }
            }
            [objects addChild:placeholder];
        }
        {
            NSXMLElement *placeholder = [NSXMLElement elementWithName:@"placeholder"];
            [placeholder setAttributesAsDictionary:@{
                @"placeholderIdentifier" : @"IBFirstResponder",
                @"id" : @"-2",
                @"customClass" : @"UIResponder",
            }];
            [objects addChild:placeholder];
        }
        {
            NSDictionary *hierarchy = [self xib_buildHierarchy:layer];
            NSString *code =
                [[context[layer.layerClass][@"xib_code"] callWithArguments:@[ layer.layerID, hierarchy ]] toString];
            if (code != nil) {
                NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:code error:nil];
                if (element != nil) {
                    [objects addChild:element];
                }
            }
        }
        [rootElement addChild:objects];
    }
    {
        if (context[layer.layerClass][@"xib_global"] != nil) {
            NSDictionary *hierarchy = [self xib_buildHierarchy:layer];
            NSString *modifiedXMLString = [[context[layer.layerClass][@"xib_global"]
                callWithArguments:@[ layer.layerID, hierarchy, rootElement.XMLString ]] toString];
            NSXMLElement *_rootElement = [[NSXMLElement alloc] initWithXMLString:modifiedXMLString error:nil];
            if (_rootElement != nil) {
                rootElement = _rootElement;
            }
        }
    }
    [document addChild:rootElement];
    return document;
}

- (NSNumber *)xib_automaticallyAdjustsScrollViewInsets:(COMGenLayer *)layer {
    if ([layer.props[@"adjustInset"] isKindOfClass:[NSNumber class]] && [layer.props[@"adjustInset"] boolValue]) {
        return layer.props[@"adjustInset"];
    } else {
        for (COMGenLayer *sublayer in layer.sublayers) {
            NSNumber *sublayerResult = [self xib_automaticallyAdjustsScrollViewInsets:sublayer];
            if (sublayerResult != nil) {
                return sublayerResult;
            }
        }
    }
    return nil;
}

- (NSDictionary *)xib_buildHierarchy:(COMGenLayer *)layer {
    NSMutableArray *sublayers = [NSMutableArray array];
    for (COMGenLayer *sublayer in layer.sublayers) {
        [sublayers addObject:[self xib_buildHierarchy:sublayer]];
    }
    return @{
        @"class" : layer.layerClass,
        @"id" : layer.layerID,
        @"props" : layer.props,
        @"sublayers" : sublayers,
    };
}

@end
