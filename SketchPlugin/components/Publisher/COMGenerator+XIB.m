//
//  COMGenerator+XIB.m
//  components
//
//  Created by 崔明辉 on 2016/12/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMGenerator+XIB.h"
#import "COMGenerator+OC.h"

@implementation COMGenerator (XIB)

- (NSDictionary *)xib_code:(COMGenLayer *)layer genType:(COMGenType)genType className:(NSString *)className {
    NSDictionary *reuseCodes = [self oc_reusesCode:layer genType:genType];
    layer = [self oc_layerByTrimmingReuseLayers:layer];
    // create header code
    NSDictionary *outlets = [self xib_outlets:layer];
    NSString *superClass = genType == COMGenTypeViewController ? @"UIViewController" : @"UIView";
    NSMutableString *headerCode = [[NSMutableString alloc]
                                   initWithFormat:@"//\n//  %@.h\n//  %@\n//\n//  Created by CodeX on %@.\n\n#import <UIKit/UIKit.h>\n#import "
                                   @"\"COXRuntime.h\"\n\n@interface %@ : %@\n\n#pragma mark - CodeX Outlets\n",
                                   className, className, [NSDate date], className, superClass];
    [outlets enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [headerCode appendFormat:@"@property (nonatomic, %@) IBOutlet %@ *%@; // CodeX managed.\n",
         [obj[@"outletID"] isEqualToString:@"rootView"] ? @"strong" : @"weak",
         obj[@"class"],
         obj[@"outletID"]
         ];
    }];
    [headerCode appendString:@"\n@end\n"];
    // create xib code.
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
                                                     @"customClass" : className,
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
                [outlets enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    NSXMLElement *connectionOutlet = [NSXMLElement elementWithName:@"outlet"];
                    [connectionOutlet setAttributesAsDictionary:@{
                                                                  @"destination": key,
                                                                  @"property": obj[@"outletID"],
                                                                  @"id": [[NSUUID UUID] UUIDString],
                                                                  }];
                    [connections parent];
                    [connections addChild:connectionOutlet];
                }];
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
            [[[COMGenerator context][layer.layerClass][@"xib_code"] callWithArguments:@[ layer.layerID, hierarchy ]] toString];
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
        if ([COMGenerator context][layer.layerClass][@"xib_global"] != nil) {
            NSDictionary *hierarchy = [self xib_buildHierarchy:layer];
            NSString *modifiedXMLString = [[[COMGenerator context][layer.layerClass][@"xib_global"]
                                            callWithArguments:@[ layer.layerID, hierarchy, rootElement.XMLString ]] toString];
            NSXMLElement *_rootElement = [[NSXMLElement alloc] initWithXMLString:modifiedXMLString error:nil];
            if (_rootElement != nil) {
                rootElement = _rootElement;
            }
        }
    }
    [document addChild:rootElement];
    // return codes.
    NSMutableDictionary *codes = [NSMutableDictionary dictionary];
    [codes addEntriesFromDictionary:@{
                                      [NSString stringWithFormat:@"%@.xib", className]: [document XMLStringWithOptions:NSXMLNodePrettyPrint],
                                      [NSString stringWithFormat:@"%@.h", className]: [headerCode copy],
                                      }];
    [codes addEntriesFromDictionary:reuseCodes];
    return [codes copy];
}

- (NSDictionary *)xib_outlets:(COMGenLayer *)layer {
    NSMutableDictionary *outlets = [NSMutableDictionary dictionary];
    if (layer.props[@"outletID"] != nil && [layer.props[@"outletID"] length] > 0) {
        NSString *ocClass = [[[COMGenerator context][layer.layerClass][@"oc_class"] callWithArguments:@[layer.props]] toString];
        if (ocClass != nil) {
            outlets[layer.layerID] = @{
                                       @"outletID": layer.props[@"outletID"],
                                       @"class": ocClass,
                                       };
        }
        for (COMGenLayer *sublayer in layer.sublayers) {
            [outlets addEntriesFromDictionary:[self xib_outlets:sublayer]];
        }
    }
    return [outlets copy];
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
