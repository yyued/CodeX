//
//  COXTableViewCell.m
//  test
//
//  Created by 崔明辉 on 2016/12/29.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COXTableViewCell.h"
#import "COXRuntime.h"

static NSDictionary *cellInstances;

@implementation COXTableViewCell

+ (CGFloat)requestRowHeight:(UITableView *)tableView
         configurationBlock:(COXTableViewCellConfigurationBlock)configurationBlock {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cellInstances = [NSDictionary dictionary];
    });
    COXTableViewCell *cell;
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
    if (configurationBlock) {
        configurationBlock(cell);
        return [[cell rootView] cox_sizeThatFits:CGSizeMake(tableView.bounds.size.width, CGFLOAT_MAX)].height;
    }
    else {
        return (CGFloat)[[[cell rootView] cox_constraint].height doubleValue];
    }
    return 0.0;
}

- (UIView *)rootView {
    return nil;
}

@end
