//
//  COMGenLayer.m
//  components
//
//  Created by 崔明辉 on 2016/12/9.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMGenLayer.h"

@implementation COMGenLayer

- (id)copy {
    COMGenLayer *newLayer = [COMGenLayer new];
    newLayer.layerID = self.layerID;
    newLayer.layerClass = self.layerClass;
    newLayer.props = [self.props copy];
    NSMutableArray *sublayers = [NSMutableArray array];
    [newLayer.sublayers enumerateObjectsUsingBlock:^(COMGenLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [sublayers addObject:[obj copy]];
    }];
    newLayer.sublayers = [sublayers copy];
    return newLayer;
}

- (NSDictionary *)props {
    if (_props == nil) {
        return @{};
    }
    return _props;
}

- (NSArray<COMGenLayer *> *)sublayers {
    if (_sublayers == nil) {
        _sublayers = @[];
    }
    return _sublayers;
}

@end
