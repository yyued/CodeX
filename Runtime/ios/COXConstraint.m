//
//  COXConstraints.m
//  test
//
//  Created by 崔明辉 on 2016/12/15.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COXConstraint.h"
#import "UIView+COXRuntime.h"
#import <JavaScriptCore/JavaScriptCore.h>

@implementation COXConstraint

static JSContext *context;

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context = [JSContext new];
        [context evaluateScript:@"var f = function(origin, length, fomula) {var fixedFomula = fomula.replace(/%/ig, '/100.0*'+length);eval(\"var result = \" + fixedFomula + \";\");return result + origin;}"];
    });
}

- (CGRect)requestFrameWithMyView:(UIView *)myView superview:(UIView *)superView previousView:(UIView *)previousView {
    if (self.disabled) {
        return myView.frame;
    }
    CGFloat x = NAN, y = NAN, mx = NAN, my = NAN, cx = NAN, cy = NAN;
    CGFloat w = NAN, h = NAN;
    BOOL xorw = NO, yorh = NO;
    if (self.width != nil) {
        NSString *fomula = self.width;
        if (self.sizeRelate == COXLayoutRelateToPrevious) {
            w = [[context[@"f"] callWithArguments:@[
                                                    @(0),
                                                    @(previousView.frame.size.width),
                                                    fomula
                                                    ]] toDouble];
        }
        else {
            w = [[context[@"f"] callWithArguments:@[
                                                    @(0),
                                                    @(superView.frame.size.width),
                                                    fomula
                                                    ]] toDouble];
        }
    }
    else {
        CGSize iSize = [myView cox_intrinsicContentSize];
        if (iSize.width > 0.0) {
            w = ceilf(iSize.width);
        }
    }
    if (self.height != nil) {
        NSString *fomula = self.height;
        if (self.sizeRelate == COXLayoutRelateToPrevious) {
            h = [[context[@"f"] callWithArguments:@[
                                                    @(0),
                                                    @(previousView.frame.size.height),
                                                    fomula
                                                    ]] toDouble];
        }
        else {
            h = [[context[@"f"] callWithArguments:@[
                                                    @(0),
                                                    @(superView.frame.size.height),
                                                    fomula
                                                    ]] toDouble];
        }
    }
    else {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
        if (self.width != nil && !isnan(w) && [myView respondsToSelector:@selector(setMaxWidth:)]) {
            [myView performSelector:@selector(setMaxWidth:) withObject:@(w)];
        }
#pragma GCC diagnostic
        CGSize iSize = [myView cox_intrinsicContentSize];
        if (iSize.height > 0.0) {
            h = ceilf(iSize.height);
        }
    }
    if (self.centerHorizontally && self.aligmentRelate == COXLayoutRelateToGroup) {
        cx = superView.frame.size.width / 2.0;
    }
    else if (self.centerHorizontally && self.aligmentRelate == COXLayoutRelateToPrevious) {
        cx = previousView.center.x;
    }
    if (self.centerVertically && self.aligmentRelate == COXLayoutRelateToGroup) {
        cy = superView.frame.size.height / 2.0;
    }
    else if (self.centerVertically && self.aligmentRelate == COXLayoutRelateToPrevious) {
        cy = previousView.center.y;
    }
    if (self.top != nil) {
        NSString *fomula = self.top;
        CGFloat t = 0.0;
        if (self.pinRelate == COXLayoutRelateToGroup) {
            t = [[context[@"f"] callWithArguments:@[
                                                    @(0),
                                                    @(superView.frame.size.height),
                                                    fomula
                                                    ]] toDouble];
        }
        else if (self.pinRelate == COXLayoutRelateToPrevious) {
            t = [[context[@"f"] callWithArguments:@[
                                                    @(0),
                                                    @(previousView.frame.size.height),
                                                    fomula
                                                    ]] toDouble];
            t = previousView.frame.origin.y + t;
        }
        if (self.centerVertically) {
            cy += t;
        }
        else {
            y = t;
        }
    }
    if (self.bottom != nil) {
        NSString *fomula = self.bottom;
        CGFloat t = 0.0;
        if (self.pinRelate == COXLayoutRelateToGroup) {
            t = [[context[@"f"] callWithArguments:@[
                                                    @(0),
                                                    @(superView.frame.size.height),
                                                    fomula
                                                    ]] toDouble];
        }
        else if (self.pinRelate == COXLayoutRelateToPrevious) {
            t = [[context[@"f"] callWithArguments:@[
                                                    @(0),
                                                    @(previousView.frame.size.height),
                                                    fomula
                                                    ]] toDouble];
            t = previousView.frame.origin.y + previousView.frame.size.height - t;
        }
        if (self.centerVertically) {
            cy -= t;
        }
        else if (self.pinRelate == COXLayoutRelateToPrevious) {
            y = t;
            yorh = YES;
        }
        else {
            my = t;
        }
    }
    if (self.left != nil) {
        NSString *fomula = self.left;
        CGFloat t = 0.0;
        if (self.pinRelate == COXLayoutRelateToGroup) {
            t = [[context[@"f"] callWithArguments:@[
                                                    @(0),
                                                    @(superView.frame.size.width),
                                                    fomula
                                                    ]] toDouble];
        }
        else if (self.pinRelate == COXLayoutRelateToPrevious) {
            t = [[context[@"f"] callWithArguments:@[
                                                    @(0),
                                                    @(previousView.frame.size.width),
                                                    fomula
                                                    ]] toDouble];
            t = previousView.frame.origin.x + t;
        }
        if (self.centerHorizontally) {
            cx += t;
        }
        else {
            x = t;
        }
    }
    if (self.right != nil) {
        NSString *fomula = self.right;
        CGFloat t = 0.0;
        if (self.pinRelate == COXLayoutRelateToGroup) {
            t = [[context[@"f"] callWithArguments:@[
                                                    @(0),
                                                    @(superView.frame.size.width),
                                                    fomula
                                                    ]] toDouble];
        }
        else if (self.pinRelate == COXLayoutRelateToPrevious) {
            t = [[context[@"f"] callWithArguments:@[
                                                    @(0),
                                                    @(previousView.frame.size.width),
                                                    fomula
                                                    ]] toDouble];
            t = previousView.frame.origin.x + previousView.frame.size.width - t;
        }
        if (self.centerVertically) {
            cx -= t;
        }
        else if (self.pinRelate == COXLayoutRelateToPrevious) {
            x = t;
            xorw = YES;
        }
        else {
            mx = t;
        }
    }
    CGRect newFrame = CGRectMake(!isnan(cx) ? cx : (!isnan(x) ? x : 0.0),
                                 !isnan(cy) ? cy : (!isnan(y) ? y : 0.0),
                                 !isnan(w) ? w : 0.0,
                                 !isnan(h) ? h : 0.0
                                 );
    if (!isnan(cx)) {
        newFrame.origin.x -= newFrame.size.width / 2.0;
    }
    if (!isnan(cy)) {
        newFrame.origin.y -= newFrame.size.height / 2.0;
    }
    if (!isnan(mx) && isnan(x)) {
        if (self.pinRelate == COXLayoutRelateToGroup) {
            newFrame.origin.x = superView.frame.size.width - mx - newFrame.size.width;
        }
        else if (self.pinRelate == COXLayoutRelateToPrevious) {
            newFrame.origin.x = previousView.frame.size.width - mx - newFrame.size.width;
        }
    }
    if (!isnan(my) && isnan(y)) {
        if (self.pinRelate == COXLayoutRelateToGroup) {
            newFrame.origin.y = superView.frame.size.height - my - newFrame.size.height;
        }
        else if (self.pinRelate == COXLayoutRelateToPrevious) {
            newFrame.origin.y = previousView.frame.size.height - my - newFrame.size.height;
        }
    }
    if (!isnan(mx) && !isnan(x)) {
        if (self.pinRelate == COXLayoutRelateToGroup) {
            newFrame.size.width = superView.frame.size.width - mx - x;
        }
        else if (self.pinRelate == COXLayoutRelateToPrevious) {
            newFrame.size.width = previousView.frame.size.width - mx - (x - previousView.frame.origin.x);
        }
    }
    if (!isnan(my) && !isnan(y)) {
        if (self.pinRelate == COXLayoutRelateToGroup) {
            newFrame.size.height = superView.frame.size.height - my - y;
        }
        else if (self.pinRelate == COXLayoutRelateToPrevious) {
            newFrame.size.height = previousView.frame.size.height - my - (y - previousView.frame.origin.y);
        }
    }
    if (xorw) {
        newFrame.origin.x -= newFrame.size.width;
    }
    if (yorh) {
        newFrame.origin.y -= newFrame.size.height;
    }
    newFrame.origin.x = isnan(newFrame.origin.x) ? 0.0 : newFrame.origin.x;
    newFrame.origin.y = isnan(newFrame.origin.y) ? 0.0 : newFrame.origin.y;
    newFrame.size.width = isnan(newFrame.size.width) ? 0.0 : newFrame.size.width;
    newFrame.size.height = isnan(newFrame.size.height) ? 0.0 : newFrame.size.height;
    return newFrame;
}

@end
