//
//  COXCollectionViewCell.m
//  test
//
//  Created by 崔明辉 on 2016/12/29.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COXCollectionViewCell.h"
#import "COXRuntime.h"

static NSDictionary *cellInstances;

@implementation COXCollectionViewCell

+ (CGSize)requestCellSize:(UICollectionView *)collectionView
       configurationBlock:(COXCollectionViewCellConfigurationBlock)configurationBlock {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cellInstances = [NSDictionary dictionary];
    });
    COXCollectionViewCell *cell;
    if ([NSThread isMainThread]) {
        if (cellInstances[NSStringFromClass([self class])] == nil) {
            NSMutableDictionary *tmp = [cellInstances mutableCopy];
            tmp[NSStringFromClass([self class])] = [[self class] new];
            cellInstances = [tmp copy];
        }
        if (cellInstances[NSStringFromClass([self class])] != nil) {
            cell = cellInstances[NSStringFromClass([self class])];
        }
    }
    else {
        cell = [[self class] new];
    }
    return CGSizeMake([[[[cell rootView] cox_constraint] width] doubleValue],
                      [[[[cell rootView] cox_constraint] height] doubleValue]);
}

- (UIView *)rootView {
    return nil;
}

@end
