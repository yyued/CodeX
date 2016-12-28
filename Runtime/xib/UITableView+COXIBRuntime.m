//
//  UITableView+COXIBRuntime.m
//  ttt
//
//  Created by 崔 明辉 on 2016/12/28.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "UITableView+COXIBRuntime.h"

@implementation UITableView (COXIBRuntime)

- (NSString *)cox_reuseIdentifier {
    return nil;
}

- (void)setCox_reuseIdentifier:(NSString *)cox_reuseIdentifier {
    [self registerClass:NSClassFromString(cox_reuseIdentifier) forCellReuseIdentifier:cox_reuseIdentifier];
}

@end
