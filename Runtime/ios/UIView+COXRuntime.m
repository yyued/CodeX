//
//  UIView+COXRuntime.m
//  ttt
//
//  Created by 崔 明辉 on 2016/12/11.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "UIView+COXRuntime.h"
#import <objc/runtime.h>
#import <JavaScriptCore/JavaScriptCore.h>

@implementation UIView (COXRuntime)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      Class class = [self class];
      SEL originalSelector = @selector(layoutSubviews);
      SEL swizzledSelector = @selector(cox_layoutSubviews);
      Method originalMethod = class_getInstanceMethod(class, originalSelector);
      Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
      BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod),
                                          method_getTypeEncoding(swizzledMethod));

      if (didAddMethod) {
          class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod),
                              method_getTypeEncoding(originalMethod));
      } else {
          method_exchangeImplementations(originalMethod, swizzledMethod);
      }
    });
}

- (void)cox_layoutSubviews {
    [self cox_layoutSubviews];
    UIView *previous;
    for (UIView *subview in self.subviews) {
        if (subview.cox_constraint != nil && !subview.cox_constraint.disabled) {
            subview.frame =
                [subview.cox_constraint requestFrameWithMyView:subview superview:self previousView:previous];
        }
        [subview automaticallyAdjustsTopSpace];
        previous = subview;
    }
}

- (CGSize)cox_sizeThatFits:(CGSize)size {
    self.frame = CGRectMake(0, 0, size.width, 0);
    [self layoutSubviews];
    return [self cox_sizeThatFits:size offset:0.0];
}

- (CGSize)cox_sizeThatFits:(CGSize)size offset:(CGFloat)offset {
    CGSize currentSize = CGSizeMake(size.width, 0);
    for (UIView *subview in self.subviews) {
        currentSize.height = MAX(currentSize.height,
                                 [subview cox_sizeThatFits:CGSizeMake(subview.frame.size.width,
                                                                      CGFLOAT_MAX)
                                                    offset:self.frame.origin.y].height
                                 );
    }
    if (self.cox_constraint != nil && !self.cox_constraint.disabled && [self.cox_constraint sizeCanFit]) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
        if ([self respondsToSelector:@selector(setMaxWidth:)]) {
            [self setValue:@(size.width) forKey:@"maxWidth"];
        }
#pragma GCC diagnostic
        CGFloat top = (CGFloat)[self.cox_constraint.top doubleValue];
        CGFloat bottom = (CGFloat)[self.cox_constraint.bottom doubleValue];
        currentSize.height = offset + top + [self cox_intrinsicContentSize].height + bottom;
    }
    return currentSize;
}

- (CGSize)cox_intrinsicContentSize {
    return [self intrinsicContentSize];
}

static int kAutomaticallyAdjustsSpace;

- (BOOL)cox_automaticallyAdjustsSpace {
    return [objc_getAssociatedObject(self, &kAutomaticallyAdjustsSpace) boolValue];
}

- (void)setCox_automaticallyAdjustsSpace:(BOOL)cox_automaticallyAdjustsSpace {
    objc_setAssociatedObject(self, &kAutomaticallyAdjustsSpace, @(cox_automaticallyAdjustsSpace),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)automaticallyAdjustsTopSpace {
    if (self.cox_automaticallyAdjustsSpace) {
        UIViewController *viewController = (id)[self nextResponder];
        while (viewController != nil) {
            if ([viewController isKindOfClass:[UIViewController class]]) {
                CGFloat topSpace = [viewController.topLayoutGuide length];
                CGFloat bottomSpace = [viewController.bottomLayoutGuide length];
                CGRect frame = self.frame;
                frame.origin.y = topSpace;
                frame.size.height = self.superview.bounds.size.height - topSpace - bottomSpace;
                self.frame = frame;
                break;
            }
            viewController = (id)[viewController nextResponder];
        }
    }
}

static int kConstraintTag;

- (COXConstraint *)cox_constraint {
    return objc_getAssociatedObject(self, &kConstraintTag);
}

- (void)setCox_constraint:(COXConstraint *)cox_constraint {
    objc_setAssociatedObject(self, &kConstraintTag, cox_constraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
