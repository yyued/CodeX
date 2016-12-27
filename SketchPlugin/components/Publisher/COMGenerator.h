//
//  COMGenerator.h
//  components
//
//  Created by 崔明辉 on 2016/12/9.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SVGKit/SVGKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "COMGenLayer.h"

typedef enum : NSUInteger {
    COMGenTypeViewController,
    COMGenTypeView,
} COMGenType;

@interface COMGenerator : NSObject

@property (nonatomic, strong) NSString *assetsPath;
@property (nonatomic, strong) NSString *libraryPath;
@property (nonatomic, strong) NSString *className;

+ (JSContext *)context;

- (COMGenLayer *)parse;

@end
