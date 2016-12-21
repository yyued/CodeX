//
//  UIButton+COXRuntime.m
//  test
//
//  Created by 崔明辉 on 2016/12/13.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "UIButton+COXRuntime.h"

@interface COXButton ()

@property (nonatomic, strong) UIButton *mButton;
@property (nonatomic, readwrite) BOOL highlighted;

@end

@implementation COXButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createButton];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self createButton];
    }
    return self;
}

- (void)createButton {
    self.mButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.mButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mButton.frame = self.bounds;
    [self.mButton addTarget:self action:@selector(resetState) forControlEvents:UIControlEventTouchCancel];
    [self.mButton addTarget:self action:@selector(resetState) forControlEvents:UIControlEventTouchDragExit];
    [self.mButton addTarget:self action:@selector(resetState) forControlEvents:UIControlEventTouchUpInside];
    [self.mButton addTarget:self action:@selector(resetState) forControlEvents:UIControlEventTouchUpOutside];
    [self.mButton addTarget:self action:@selector(resetState) forControlEvents:UIControlEventTouchDragEnter];
    [self.mButton addTarget:self action:@selector(resetState) forControlEvents:UIControlEventTouchDragInside];
    [self.mButton addTarget:self action:@selector(resetState) forControlEvents:UIControlEventTouchDragOutside];
    [self.mButton addTarget:self action:@selector(resetState) forControlEvents:UIControlEventTouchDown];
    [self addSubview:self.mButton];
    self.userInteractionEnabled = YES;
}

- (void)resetState {
    [self _resetState];
    [NSTimer scheduledTimerWithTimeInterval:0.01
                                     target:self
                                   selector:@selector(_resetState)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)_resetState {
    [self setCondition:self.state animated:self.animated];
}

- (UIControlState)state {
    return self.mButton.state;
}

- (BOOL)highlighted {
    return self.mButton.highlighted;
}

- (BOOL)enabled {
    return self.mButton.enabled;
}

- (void)setEnabled:(BOOL)enabled {
    [self.mButton setEnabled:enabled];
    [self resetState];
}

- (BOOL)selected {
    return self.mButton.selected;
}

- (void)setSelected:(BOOL)selected {
    [self.mButton setSelected:selected];
    [self resetState];
}

- (void)setView:(UIView *)view forCondition:(UIControlState)condition {
    [super setView:view forCondition:(NSInteger)condition];
}

- (void)setBlock:(COXConditionBlock)block forCondition:(UIControlState)condition {
    [super setBlock:block forCondition:(NSInteger)condition];
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    [self.mButton addTarget:target action:action forControlEvents:controlEvents];
}

- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    [self.mButton removeTarget:target action:action forControlEvents:controlEvents];
}

@end
