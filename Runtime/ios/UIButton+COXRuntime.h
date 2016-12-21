//
//  UIButton+COXRuntime.h
//  test
//
//  Created by 崔明辉 on 2016/12/13.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COXConditionView.h"

@interface COXButton: COXConditionView

/**
 could be more than one state (e.g. disabled|selected). synthesized from other flags.
 */
@property (nonatomic, readonly) UIControlState state;

/**
 default is NO. this gets set/cleared automatically when touch enters/exits during tracking and cleared on up
 */
@property (nonatomic, readonly) BOOL highlighted;

/**
 default is YES. if NO, ignores touch events and subclasses may draw differently
 */
@property (nonatomic, assign) BOOL enabled;

/**
 default is NO may be used by some subclasses or by application
 */
@property (nonatomic, assign) BOOL selected;

/**
 default is NO, tells COXButton should change view with animation
 */
@property (nonatomic, assign) BOOL animated;

/**
 * Set view for state.
 */
- (void)setView:(UIView *)view forCondition:(UIControlState)condition;

/**
 * Set block for state.
 */
- (void)setBlock:(COXConditionBlock)block forCondition:(UIControlState)condition;

/**
 add target/action for particular event. you can call this multiple times and you can specify multiple target/actions for a particular event.
 passing in nil as the target goes up the responder chain. The action may optionally include the sender and the event in that order
 the action cannot be NULL. Note that the target is not retained.
 */
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

/**
 remove the target/action for a set of events. pass in NULL for the action to remove all actions for that target
 */
- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end
