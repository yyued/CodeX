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

static JSContext *context;
static int kConstraintsKey;

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector = @selector(layoutSubviews);
        SEL swizzledSelector = @selector(cox_layoutSubviews);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        context = [JSContext new];
        [context evaluateScript:@"var f = function(origin, length, fomula) {var fixedFomula = fomula.replace(/%/ig, '/100.0*'+length);eval(\"var result = \" + fixedFomula + \";\");return result + origin;}"];
    });
}

- (void)cox_layoutSubviews {
    [self cox_layoutSubviews];
    UIView *previous;
    for (UIView *subview in self.subviews) {
        if (subview.cox_constraints != nil) {
            CGFloat x = NAN, y = NAN, mx = NAN, my = NAN, cx = NAN, cy = NAN;
            CGFloat w = NAN, h = NAN;
            if ([subview cox_fixedWidth]) {
                NSString *fomula = subview.cox_constraints[@"fixedWidth"] != nil ? subview.cox_constraints[@"fixedWidth"] : @"";
                if ([subview.cox_constraints[@"sizeRelativeTo"] isEqualToString:@"2"]) {
                    w = [[context[@"f"] callWithArguments:@[
                                                            @(0),
                                                            @(previous.frame.size.width),
                                                            fomula
                                                            ]] toDouble];
                }
                else {
                    w = [[context[@"f"] callWithArguments:@[
                                                           @(0),
                                                           @(self.frame.size.width),
                                                           fomula
                                                           ]] toDouble];
                }
            }
            if ([subview cox_fixedHeight]) {
                NSString *fomula = subview.cox_constraints[@"fixedHeight"] != nil ? subview.cox_constraints[@"fixedHeight"] : @"";
                if ([subview.cox_constraints[@"sizeRelativeTo"] isEqualToString:@"2"]) {
                    h = [[context[@"f"] callWithArguments:@[
                                                            @(0),
                                                            @(previous.frame.size.height),
                                                            fomula
                                                            ]] toDouble];
                }
                else {
                    h = [[context[@"f"] callWithArguments:@[
                                                            @(0),
                                                            @(self.frame.size.height),
                                                            fomula
                                                            ]] toDouble];
                }
            }
            if ([subview cox_centerXToGroup]) {
                cx = self.frame.size.width / 2.0;
            }
            else if ([subview cox_centerXToPrevious]) {
                cx = previous.center.x;
            }
            if ([subview cox_centerYToGroup]) {
                cy = self.frame.size.height / 2.0;
            }
            else if ([subview cox_centerYToPrevious]) {
                cy = previous.center.y;
            }
            if ([subview cox_topPinning]) {
                NSString *fomula = subview.cox_constraints[@"topPinning"] != nil ? subview.cox_constraints[@"topPinning"] : @"";
                CGFloat t = 0.0;
                if ([subview cox_pinToGroup]) {
                    t = [[context[@"f"] callWithArguments:@[
                                                            @(0),
                                                            @(self.frame.size.height),
                                                            fomula
                                                            ]] toDouble];
                }
                else if ([subview cox_pinToPrevious]) {
                    t = [[context[@"f"] callWithArguments:@[
                                                            @(0),
                                                            @(previous.frame.size.height),
                                                            fomula
                                                            ]] toDouble];
                }
                if ([subview cox_centerYToGroup] || [subview cox_centerYToPrevious]) {
                    cy += t;
                }
                else {
                    y = t;
                }
            }
            if ([subview cox_bottomPinning]) {
                NSString *fomula = subview.cox_constraints[@"bottomPinning"] != nil ? subview.cox_constraints[@"bottomPinning"] : @"";
                CGFloat t = 0.0;
                if ([subview cox_pinToGroup]) {
                    t = [[context[@"f"] callWithArguments:@[
                                                            @(0),
                                                            @(self.frame.size.height),
                                                            fomula
                                                            ]] toDouble];
                }
                else if ([subview cox_pinToPrevious]) {
                    t = [[context[@"f"] callWithArguments:@[
                                                            @(0),
                                                            @(previous.frame.size.height),
                                                            fomula
                                                            ]] toDouble];
                }
                if ([subview cox_centerYToGroup] || [subview cox_centerYToPrevious]) {
                    cy -= t;
                }
                else {
                    my = t;
                }
            }
            if ([subview cox_leftPinning]) {
                NSString *fomula = subview.cox_constraints[@"leftPinning"] != nil ? subview.cox_constraints[@"leftPinning"] : @"";
                CGFloat t = 0.0;
                if ([subview cox_pinToGroup]) {
                    t = [[context[@"f"] callWithArguments:@[
                                                            @(0),
                                                            @(self.frame.size.width),
                                                            fomula
                                                            ]] toDouble];
                }
                else if ([subview cox_pinToPrevious]) {
                    t = [[context[@"f"] callWithArguments:@[
                                                            @(0),
                                                            @(previous.frame.size.width),
                                                            fomula
                                                            ]] toDouble];
                }
                if ([subview cox_centerXToGroup] || [subview cox_centerXToPrevious]) {
                    cx += t;
                }
                else {
                    x = t;
                }
            }
            if ([subview cox_rightPinning]) {
                NSString *fomula = subview.cox_constraints[@"rightPinning"] != nil ? subview.cox_constraints[@"rightPinning"] : @"";
                CGFloat t = 0.0;
                if ([subview cox_pinToGroup]) {
                    t = [[context[@"f"] callWithArguments:@[
                                                            @(0),
                                                            @(self.frame.size.width),
                                                            fomula
                                                            ]] toDouble];
                }
                else if ([subview cox_pinToPrevious]) {
                    t = [[context[@"f"] callWithArguments:@[
                                                            @(0),
                                                            @(previous.frame.size.width),
                                                            fomula
                                                            ]] toDouble];
                }
                if ([subview cox_centerXToGroup] || [subview cox_centerXToPrevious]) {
                    cx -= t;
                }
                else {
                    mx = t;
                }
            }
            CGRect newFrame = CGRectMake(!isnan(cx) ? cx : (!isnan(x) ? x : 0.0),
                                         !isnan(cy) ? cy : (!isnan(y) ? y : 0.0),
                                         !isnan(w) ? w : (!isnan(mx) && !isnan(x) ? mx - x : 0.0),
                                         !isnan(h) ? h : (!isnan(my) && !isnan(y) ? my - y : 0.0));
            if (!isnan(cx)) {
                newFrame.origin.x -= newFrame.size.width / 2.0;
            }
            if (!isnan(cy)) {
                newFrame.origin.y -= newFrame.size.height / 2.0;
            }
            subview.frame = newFrame;
        }
        previous = subview;
    }
}

- (NSDictionary *)cox_constraints {
    return objc_getAssociatedObject(self, &kConstraintsKey);
}

- (void)setCox_constraints:(NSDictionary *)cox_constraints {
    objc_setAssociatedObject(self, &kConstraintsKey, cox_constraints, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIView *)cox_rootView {
    UIView *current = self.superview;
    while (current != nil) {
        if (current.tag == 999999999) {
            return current;
        }
        current = current.superview;
    }
    return nil;
}

- (BOOL)cox_centerXToGroup {
    return ![self.cox_constraints[@"centerRelativeTo"] isEqualToString:@"2"] && [self.cox_constraints[@"centerHorizontally"] isEqualToString:@"1"];
}

- (BOOL)cox_centerYToGroup {
    return ![self.cox_constraints[@"centerRelativeTo"] isEqualToString:@"2"] && [self.cox_constraints[@"centerVertically"] isEqualToString:@"1"];
}

- (BOOL)cox_centerXToPrevious {
    return [self.cox_constraints[@"centerRelativeTo"] isEqualToString:@"2"] && [self.cox_constraints[@"centerHorizontally"] isEqualToString:@"1"];
}

- (BOOL)cox_centerYToPrevious {
    return [self.cox_constraints[@"centerRelativeTo"] isEqualToString:@"2"] && [self.cox_constraints[@"centerVertically"] isEqualToString:@"1"];
}

- (BOOL)cox_fixedWidth {
    return [self.cox_constraints[@"useFixedWidth"] isEqualToString:@"1"];
}

- (BOOL)cox_fixedHeight {
    return [self.cox_constraints[@"useFixedHeight"] isEqualToString:@"1"];
}

- (BOOL)cox_pinToGroup {
    return ![self.cox_constraints[@"pinRelativeTo"] isEqualToString:@"2"];
}

- (BOOL)cox_pinToPrevious {
    return [self.cox_constraints[@"pinRelativeTo"] isEqualToString:@"2"];
}

- (BOOL)cox_topPinning {
    return [self.cox_constraints[@"useTopPinning"] isEqualToString:@"1"];
}

- (BOOL)cox_leftPinning {
    return [self.cox_constraints[@"useLeftPinning"] isEqualToString:@"1"];
}

- (BOOL)cox_bottomPinning {
    return [self.cox_constraints[@"useBottomPinning"] isEqualToString:@"1"];
}

- (BOOL)cox_rightPinning {
    return [self.cox_constraints[@"useRightPinning"] isEqualToString:@"1"];
}

@end
