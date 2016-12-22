//
//  COXConditionView.m
//  test
//
//  Created by 崔明辉 on 2016/12/21.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COXConditionView.h"

@interface COXConditionView ()

@property (nonatomic, copy) NSDictionary<NSNumber *, UIView *> *views;
@property (nonatomic, copy) NSDictionary<NSNumber *, COXConditionBlock> *blocks;

@end

@implementation COXConditionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _views = @{};
        _blocks = @{};
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _views = @{};
        _blocks = @{};
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    [self resetConditionView];
}

- (void)setView:(UIView *)view forCondition:(NSInteger)condition {
    if (view == nil) {
        [self.views[@(condition)] removeFromSuperview];
        NSMutableDictionary *views = [self.views mutableCopy];
        [views removeObjectForKey:@(condition)];
        self.views = views;
        return;
    }
    NSMutableDictionary *views = [self.views mutableCopy];
    [views setObject:view forKey:@(condition)];
    self.views = views;
    view.alpha = 0.0;
    [self insertSubview:view atIndex:0];
}

- (void)setBlock:(COXConditionBlock)block forCondition:(NSInteger)condition {
    if (block == nil) {
        NSMutableDictionary *blocks = [self.blocks mutableCopy];
        [blocks removeObjectForKey:@(condition)];
        self.blocks = blocks;
        return;
    }
    NSMutableDictionary *blocks = [self.blocks mutableCopy];
    [blocks setObject:[block copy] forKey:@(condition)];
    self.blocks = blocks;
}

- (void)resetConditionView {
    if (self.views.count == 0 && self.subviews.count > 0) {
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.tag >= 0) {
                [self setView:obj forCondition:obj.tag];
            }
        }];
    }
    if (self.views[@(self.condition)] != nil) {
        for (NSNumber *aKey in self.views) {
            self.views[aKey].alpha = 0.0;
        }
        self.views[@(self.condition)].alpha = 1.0;
    }
    if (self.blocks[@(self.condition)] != nil) {
        self.blocks[@(self.condition)]();
    }
}

- (void)setCondition:(NSInteger)condition {
    if (_condition == condition) {
        return;
    }
    _condition = condition;
    [self resetConditionView];
}

- (void)setCondition:(NSInteger)condition animated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self setCondition:condition];
        } completion:nil];
    }
    else {
        [self setCondition:condition];
    }
}

@end
