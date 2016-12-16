//
//  UIViewController+COXRuntime.h
//  test
//
//  Created by 崔明辉 on 2016/12/16.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (COXRuntime)

+ (void)cox_setStatusBarStyle:(UIStatusBarStyle)style;
+ (void)cox_setStatusBarHidden:(BOOL)hidden animation:(UIStatusBarAnimation)animation;
- (void)cox_setStatusBarStyle:(UIStatusBarStyle)style;
- (void)cox_setStatusBarHidden:(BOOL)hidden animation:(UIStatusBarAnimation)animation;

@end
