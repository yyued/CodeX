//
//  UIView+COXIBRuntime.h
//  test
//
//  Created by 崔明辉 on 2016/12/26.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COXRuntime.h"

@interface UIView (COXIBRuntime)

@property (nonatomic, assign) BOOL cox_constraintEnabled;
@property (nonatomic, strong) UIColor *cox_borderColor;

@end
