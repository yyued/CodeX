//
//  UIViewController+COXRuntime.m
//  test
//
//  Created by 崔明辉 on 2016/12/16.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "UIViewController+COXRuntime.h"
#import <objc/runtime.h>

@implementation UIViewController (COXRuntime)

static NSMutableDictionary *defaultStatusBarStyle;
static NSMutableDictionary *defaultStatusBarHidden;
static NSMutableDictionary *defaultStatusBarAnimation;

+ (BOOL)cox_isUIViewControllerBasedStatusBarAppearance {
    if ([[NSBundle mainBundle] infoDictionary][@"UIViewControllerBasedStatusBarAppearance"] == nil) {
        return YES;
    }
    return [[[NSBundle mainBundle] infoDictionary][@"UIViewControllerBasedStatusBarAppearance"] boolValue];
}

+ (void)cox_setStatusBarStyle:(UIStatusBarStyle)style {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultStatusBarStyle = [NSMutableDictionary dictionary];
    });
    Class class = [self class];
    defaultStatusBarStyle[NSStringFromClass(class)] = @(style);
    [self cox_statusBarMethodSwizzling];
}

+ (void)cox_setStatusBarHidden:(BOOL)hidden animation:(UIStatusBarAnimation)animation {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultStatusBarHidden = [NSMutableDictionary dictionary];
        defaultStatusBarAnimation = [NSMutableDictionary dictionary];
    });
    Class class = [self class];
    defaultStatusBarHidden[NSStringFromClass(class)] = @(hidden);
    defaultStatusBarAnimation[NSStringFromClass(class)] = @(animation);
    [self cox_statusBarMethodSwizzling];
}

+ (void)cox_statusBarMethodSwizzling {
    Class class = [self class];
    if ([self cox_isUIViewControllerBasedStatusBarAppearance]) {
        {
            SEL originalSelector = @selector(preferredStatusBarStyle);
            SEL swizzledSelector = @selector(cox_preferredStatusBarStyle);
            Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
            class_addMethod(class,
                            originalSelector,
                            method_getImplementation(swizzledMethod),
                            method_getTypeEncoding(swizzledMethod));
        }
        {
            SEL originalSelector = @selector(prefersStatusBarHidden);
            SEL swizzledSelector = @selector(cox_prefersStatusBarHidden);
            Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
            class_addMethod(class,
                            originalSelector,
                            method_getImplementation(swizzledMethod),
                            method_getTypeEncoding(swizzledMethod));
        }
        {
            SEL originalSelector = @selector(preferredStatusBarUpdateAnimation);
            SEL swizzledSelector = @selector(cox_preferredStatusBarUpdateAnimation);
            Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
            class_addMethod(class,
                            originalSelector,
                            method_getImplementation(swizzledMethod),
                            method_getTypeEncoding(swizzledMethod));
        }
    }
}

static int kCOXStatusBarStyleTag;
static int kCOXStatusBarHiddenTag;
static int kCOXStatusBarAnimationTag;

- (void)cox_setStatusBarStyle:(UIStatusBarStyle)style {
    if ([[self class] cox_isUIViewControllerBasedStatusBarAppearance]) {
        [[self class] cox_statusBarMethodSwizzling];
        objc_setAssociatedObject(self, &kCOXStatusBarStyleTag, @(style), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self setNeedsStatusBarAppearanceUpdate];
    }
    else {
        [[UIApplication sharedApplication] setStatusBarStyle:style];
    }
}

- (void)cox_setStatusBarHidden:(BOOL)hidden animation:(UIStatusBarAnimation)animation {
    if ([[self class] cox_isUIViewControllerBasedStatusBarAppearance]) {
        [[self class] cox_statusBarMethodSwizzling];
        objc_setAssociatedObject(self, &kCOXStatusBarHiddenTag, @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, &kCOXStatusBarAnimationTag, @(animation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self setNeedsStatusBarAppearanceUpdate];
    }
    else {
        [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:animation];
    }
}

- (UIStatusBarStyle)cox_preferredStatusBarStyle {
    if (objc_getAssociatedObject(self, &kCOXStatusBarStyleTag) != nil) {
        return [objc_getAssociatedObject(self, &kCOXStatusBarStyleTag) integerValue];
    }
    return [defaultStatusBarStyle[NSStringFromClass([self class])] integerValue];
}

- (BOOL)cox_prefersStatusBarHidden {
    if (objc_getAssociatedObject(self, &kCOXStatusBarHiddenTag) != nil) {
        return [objc_getAssociatedObject(self, &kCOXStatusBarHiddenTag) boolValue];
    }
    return [defaultStatusBarHidden[NSStringFromClass([self class])] boolValue];
}

- (UIStatusBarAnimation)cox_preferredStatusBarUpdateAnimation {
    if (objc_getAssociatedObject(self, &kCOXStatusBarAnimationTag) != nil) {
        return [objc_getAssociatedObject(self, &kCOXStatusBarAnimationTag) integerValue];
    }
    return [defaultStatusBarAnimation[NSStringFromClass([self class])] integerValue];
}

@end
