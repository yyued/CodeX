//
//  COMGenerator+OC.m
//  components
//
//  Created by 崔明辉 on 2016/12/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMGenerator+OC.h"

@implementation COMGenerator (OC)

static NSDictionary *oc_reusable;

+ (void)load {
    oc_reusable = @{
                    @"UITableViewCell": @"COXTableViewCell",
                    };
}

- (NSDictionary *)oc_code:(COMGenLayer *)layer genType:(COMGenType)genType className:(NSString *)className {
    return [self oc_code:layer genType:genType className:className reusing:NO];
}

- (NSDictionary *)oc_code:(COMGenLayer *)layer genType:(COMGenType)genType className:(NSString *)className reusing:(BOOL)reusing {
    NSDictionary *reuseCodes = @{};
    if (!reusing) {
        reuseCodes = [self oc_reusesCode:layer genType:genType];
    }
    NSString *superClass = genType == COMGenTypeViewController ? @"UIViewController" : @"UIView";
    if (reusing && oc_reusable[layer.layerClass] != nil) {
        superClass = oc_reusable[layer.layerClass];
    }
    else {
        layer = [self oc_layerByTrimmingReuseLayers:layer];
    }
    NSMutableString *headerCode = [[NSMutableString alloc]
                                   initWithFormat:@"//\n//  %@.h\n//  %@\n//\n//  Created by CodeX on %@.\n\n#import <UIKit/UIKit.h>\n#import "
                                   @"\"COXRuntime.h\"\n\n@interface %@ : %@\n\n#pragma mark - CodeX Outlets\n",
                                   className, className, [NSDate date], className, superClass];
    NSMutableString *implementationCode = [NSMutableString string];
    NSMutableString *loadCode = [[NSMutableString alloc] initWithString:@""];
    NSMutableString *viewDidLoadCode = [[NSMutableString alloc] initWithString:@""];
    if (genType == COMGenTypeViewController) {
        implementationCode = [[NSMutableString alloc]
                              initWithFormat:
                              @"//\n//  %@.h\n//  %@\n//\n//  Created by CodeX on %@.\n\n#import \"%@.h\"\n\n#pragma mark - COXManaged Interface\n@interface %@ (COXManaged)\n\n- (void)cox_viewDidLoad;\n\n@end\n\n#pragma mark - Custom code\n@implementation %@\n\n- (void)viewDidLoad {\n    [super viewDidLoad];\n    [self cox_viewDidLoad];\n}\n\n@end\n\n#pragma mark - COXManaged implementation\n@implementation %@ (COXManaged)\n\n",
                              className, className, [NSDate date], className, className, className, className];
        [implementationCode appendString:@"- (void)loadView {\n"];
        [implementationCode appendString:@"    self.view = [self rootView];\n"];
        [implementationCode appendString:@"    self.view.backgroundColor = [UIColor whiteColor];\n"];
        [implementationCode appendString:@"}\n\n"];
    } else if (genType == COMGenTypeView) {
        NSMutableDictionary *props = [layer.props mutableCopy];
        props[@"outletID"] = @"rootView";
        NSMutableDictionary *constraints = [props[@"constraints"] mutableCopy];
        if (constraints != nil && [constraints isKindOfClass:[NSDictionary class]]) {
            constraints[@"disabled"] = @(1);
            props[@"constraints"] = constraints;
        }
        layer.props = props;
        implementationCode = [[NSMutableString alloc]
                              initWithFormat:
                              @"//\n//  %@.h\n//  %@\n//\n//  Created by CodeX on %@.\n\n#import \"%@.h\"\n\n#pragma mark - COXManaged Interface\n@interface %@ (COXManaged)\n\n- (UIView *)rootView;\n\n@end\n\n#pragma mark - Custom code\n@implementation %@\n\n@end\n\n#pragma mark - COXManaged implementation\n@implementation %@ (COXManaged)\n\n",
                              className, className, [NSDate date], className, className, className, className];
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
         appendFormat:@"\n- (void)cox_viewDidLoad {\n%@}\n\n", viewDidLoadCode];
    }
    [headerCode appendString:@"\n@end\n"];
    [implementationCode appendString:@"@end\n"];
    NSMutableDictionary *codes = [NSMutableDictionary dictionary];
    [codes addEntriesFromDictionary:@{
                                      [NSString stringWithFormat:@"%@.h", className] : [headerCode copy],
                                      [NSString stringWithFormat:@"%@.m", className] : [implementationCode copy],
                                      }];
    [codes addEntriesFromDictionary:reuseCodes];
    return [codes copy];
}

- (NSDictionary *)oc_reusesCode:(COMGenLayer *)layer genType:(COMGenType)genType {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if ([layer.layerClass isEqualToString:@"UITableViewCell"]) {
        [dict addEntriesFromDictionary:[self oc_code:layer genType:COMGenTypeView className:layer.props[@"reuseIdentifier"] reusing:yearMask]];
    }
    for (COMGenLayer *sublayer in layer.sublayers) {
        [dict addEntriesFromDictionary:[self oc_reusesCode:sublayer genType:genType]];
    }
    return [dict copy];
}

- (COMGenLayer *)oc_layerByTrimmingReuseLayers:(COMGenLayer *)layer {
    COMGenLayer *newLayer = [COMGenLayer new];
    newLayer.layerID = layer.layerID;
    newLayer.layerClass = layer.layerClass;
    newLayer.props = layer.props;
    NSMutableArray *sublayers = [NSMutableArray array];
    for (COMGenLayer *sublayer in layer.sublayers) {
        if (oc_reusable[[sublayer layerClass]] == nil) {
            [sublayers addObject:[self oc_layerByTrimmingReuseLayers:sublayer]];
        }
    }
    newLayer.sublayers = [sublayers copy];
    return newLayer;
}

- (void)oc_code:(COMGenLayer *)layer
     headerCode:(NSMutableString *)headerCode
implementationCode:(NSMutableString *)implementationCode
       loadCode:(NSMutableString *)loadCode
viewDidLoadCode:(NSMutableString *)viewDidLoadCode {
    NSString *outlet = layer.props[@"outletID"];
    {
        NSString *_loadCode = [[[COMGenerator context][layer.layerClass][@"oc_load"] callWithArguments:@[ layer.props ]] toString];
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
        [[[COMGenerator context][layer.layerClass][@"oc_viewDidLoad"] callWithArguments:@[ layer.props ]] toString];
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
    NSString *ocClass = [[[COMGenerator context][layer.layerClass][@"oc_class"] callWithArguments:@[ layer.props ]] toString];
    if ([ocClass isEqualToString:@"undefined"]) {
        return;
    }
    if (outlet != nil && outlet.length) {
        [headerCode appendFormat:@"@property (nonatomic, strong) %@ *%@; // CodeX managed.\n", ocClass, outlet];
        NSMutableString *mCode = [NSMutableString new];
        NSString *mmCode = [[[COMGenerator context][layer.layerClass][@"oc_code"] callWithArguments:@[ layer.props ]] toString];
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
                [[[COMGenerator context][sublayer.layerClass][@"oc_class"] callWithArguments:@[ sublayer.props ]] toString];
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
        NSString *mmCode = [[[COMGenerator context][layer.layerClass][@"oc_code"] callWithArguments:@[ layer.props ]] toString];
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
                [[[COMGenerator context][sublayer.layerClass][@"oc_class"] callWithArguments:@[ sublayer.props ]] toString];
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

@end
