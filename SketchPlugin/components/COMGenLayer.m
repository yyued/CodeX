//
//  COMGenLayer.m
//  components
//
//  Created by 崔明辉 on 2016/12/9.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMGenLayer.h"

@implementation COMGenLayer

- (NSArray<COMGenLayer *> *)sublayers {
    if (_sublayers == nil) {
        _sublayers = @[];
    }
    return _sublayers;
}

@end
