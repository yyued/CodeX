//
//  COMComponentSourceEntity.m
//  components
//
//  Created by 崔明辉 on 2016/12/8.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMComponentSourceEntity.h"

@implementation COMComponentSourceEntity

- (NSArray *)categories {
    NSMutableArray *categoires = [NSMutableArray array];
    [self.components enumerateObjectsUsingBlock:^(COMComponentEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *prefix = [obj.componentName componentsSeparatedByString:@"/"].firstObject;
        if (![categoires containsObject:prefix]) {
            [categoires addObject:prefix];
        }
    }];
    [categoires sortUsingSelector:@selector(compare:)];
    return categoires;
}

@end
