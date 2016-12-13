//
//  UIView+COXRuntime.h
//  ttt
//
//  Created by 崔 明辉 on 2016/12/11.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (COXRuntime)

@property (nonatomic, assign) BOOL cox_automaticallyAdjustsSpace;
@property (nonatomic, copy) NSDictionary *cox_constraints;

- (CGSize)cox_intrinsicContentSize;

@end
