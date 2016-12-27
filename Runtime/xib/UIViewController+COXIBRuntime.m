//
//  UIViewController+COXIBRuntime.m
//  test
//
//  Created by 崔明辉 on 2016/12/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "UIViewController+COXIBRuntime.h"
#import <objc/runtime.h>

@implementation UIViewController (COXIBRuntime)

static int kStatusBarStyleTag;
static int kStatusBarHiddenTag;
static int kStatusBarAnimationTag;

- (UIStatusBarStyle)cox_statusBarStyle {
    return [objc_getAssociatedObject(self, &kStatusBarStyleTag) integerValue];
}

- (void)setCox_statusBarStyle:(UIStatusBarStyle)cox_statusBarStyle {
    objc_setAssociatedObject(self, &kStatusBarStyleTag, @(cox_statusBarStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self cox_setStatusBarStyle:cox_statusBarStyle];
}

- (BOOL)cox_statusBarHidden {
    return [objc_getAssociatedObject(self, &kStatusBarHiddenTag) boolValue];
}

- (void)setCox_statusBarHidden:(BOOL)cox_statusBarHidden {
    objc_setAssociatedObject(self, &kStatusBarHiddenTag, @(cox_statusBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self cox_setStatusBarHidden:cox_statusBarHidden animation:self.cox_statusBarAnimation];
}

- (UIStatusBarAnimation)cox_statusBarAnimation {
    return [objc_getAssociatedObject(self, &kStatusBarAnimationTag) integerValue];
}

- (void)setCox_statusBarAnimation:(UIStatusBarAnimation)cox_statusBarAnimation {
    objc_setAssociatedObject(self, &kStatusBarAnimationTag, @(cox_statusBarAnimation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self cox_setStatusBarHidden:self.cox_statusBarHidden animation:cox_statusBarAnimation];
}

- (NSString *)cox_leftButtonItemText {
    return nil;
}

- (NSString *)cox_leftButtonItemImageName {
    return nil;
}

- (void)setCox_leftButtonItemText:(NSString *)cox_leftButtonItemText {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:cox_leftButtonItemText
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
}

- (void)setCox_leftButtonItemImageName:(NSString *)cox_leftButtonItemImageName {
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:cox_leftButtonItemImageName]
                                            imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
}

- (NSString *)cox_rightButtonItemText {
    return nil;
}

- (NSString *)cox_rightButtonItemImageName {
    return nil;
}

- (void)setCox_rightButtonItemText:(NSString *)cox_rightButtonItemText {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:cox_rightButtonItemText
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:nil
                                                                             action:nil];
}

- (void)setCox_rightButtonItemImageName:(NSString *)cox_rightButtonItemImageName {
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:cox_rightButtonItemImageName]
                                                   imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                         style:UIBarButtonItemStylePlain
                                        target:nil
                                        action:nil];
}

@end
