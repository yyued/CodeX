//
//  UIImageView+COXIBRuntime.m
//  test
//
//  Created by 崔明辉 on 2016/12/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "UIImageView+COXIBRuntime.h"

@implementation UIImageView (COXIBRuntime)

- (NSString *)cox_imageName {
    return nil;
}

- (void)setCox_imageName:(NSString *)cox_imageName {
    [self setImage:[UIImage imageNamed:cox_imageName]];
}

@end
