//
//  UICollectionView+COXIBRuntime.m
//  test
//
//  Created by 崔明辉 on 2016/12/29.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "UICollectionView+COXIBRuntime.h"

@implementation UICollectionView (COXIBRuntime)

- (NSString *)cox_reuseIdentifier {
    return nil;
}

- (void)setCox_reuseIdentifier:(NSString *)cox_reuseIdentifier {
    [self registerClass:NSClassFromString(cox_reuseIdentifier) forCellWithReuseIdentifier:cox_reuseIdentifier];
}

@end
