//
//  UINavigationController+COXRuntime.m
//  test
//
//  Created by 崔明辉 on 2016/12/19.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "UINavigationController+COXRuntime.h"

@implementation UINavigationController (COXRuntime)

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.visibleViewController;
}
- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.visibleViewController;
}

@end
