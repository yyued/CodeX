//
//  UIViewController+COXIBRuntime.h
//  test
//
//  Created by 崔明辉 on 2016/12/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COXRuntime.h"

@interface UIViewController (COXIBRuntime)

@property (nonatomic, assign) BOOL cox_statusBarHidden;
@property (nonatomic, assign) UIStatusBarStyle cox_statusBarStyle;
@property (nonatomic, assign) UIStatusBarAnimation cox_statusBarAnimation;
@property (nonatomic, strong) NSString *cox_leftButtonItemText;
@property (nonatomic, strong) NSString *cox_leftButtonItemImageName;
@property (nonatomic, strong) NSString *cox_rightButtonItemText;
@property (nonatomic, strong) NSString *cox_rightButtonItemImageName;

@end
