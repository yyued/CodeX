//
//  COXConstraints.h
//  test
//
//  Created by 崔明辉 on 2016/12/15.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum COXLayoutRelate : NSUInteger {
    COXLayoutRelateToGroup = 0,
    COXLayoutRelateToPrevious,
} COXLayoutRelate;

@interface COXConstraint : NSObject

@property(nonatomic, assign) BOOL disabled;

@property(nonatomic, assign) COXLayoutRelate aligmentRelate;
@property(nonatomic, assign) BOOL centerHorizontally;
@property(nonatomic, assign) BOOL centerVertically;

@property(nonatomic, assign) COXLayoutRelate sizeRelate;
@property(nonatomic, copy) NSString *width;
@property(nonatomic, copy) NSString *height;

@property(nonatomic, assign) COXLayoutRelate pinRelate;
@property(nonatomic, copy) NSString *top;
@property(nonatomic, copy) NSString *left;
@property(nonatomic, copy) NSString *right;
@property(nonatomic, copy) NSString *bottom;

- (void)setNeedsLayout;

- (CGRect)requestFrameWithMyView:(UIView *)myView
                       superview:(UIView *)superView
                    previousView:(UIView *)previousView;

- (BOOL)sizeCanFit;

@end
