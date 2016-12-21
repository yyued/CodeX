//
//  COXConditionView.h
//  test
//
//  Created by 崔明辉 on 2016/12/21.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^COXConditionBlock)();

/**
 You use COXConditionView to display different view with different condition.
 */
@interface COXConditionView : UIView

@property (nonatomic, assign) NSInteger condition;

- (void)setView:(UIView *)view forCondition:(NSInteger)condition;

- (void)setBlock:(COXConditionBlock)block forCondition:(NSInteger)condition;

- (void)setCondition:(NSInteger)condition animated:(BOOL)animated;

@end
