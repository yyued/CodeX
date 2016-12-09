//
//  COMGenerator.h
//  components
//
//  Created by 崔明辉 on 2016/12/9.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SVGKit/SVGKit.h>
#import "COMGenLayer.h"

@interface COMGenerator : NSObject

- (COMGenLayer *)parse;

- (NSString *)oc_code:(COMGenLayer *)layer;

@end
