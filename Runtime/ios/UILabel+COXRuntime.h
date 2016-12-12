//
//  UILabel+COXRuntime.h
//  test
//
//  Created by 崔明辉 on 2016/12/12.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+COXRuntime.h"

@interface COXLabel: UILabel

/**
 字符间距
 */
@property (nonatomic, assign) CGFloat letterSpace;

/**
 行距
 */
@property (nonatomic, assign) CGFloat lineSpace;

/**
 下划线样式
 */
@property (nonatomic, assign) NSUnderlineStyle underlineStyle;

/**
 删除线样式
 */
@property (nonatomic, assign) NSUnderlineStyle deletelineStyle;

/**
 描边颜色
 */
@property (nonatomic, strong) UIColor *strokeColor;

/**
 描边像素
 */
@property (nonatomic, assign) CGFloat strokeWidth;

/**
 最大宽度
 */
@property (nonatomic, assign) CGFloat maxWidth;

/**
 设置字体
 */
- (void)setFontWithFamilyName:(NSString *)familyName fontSize:(CGFloat)fontSize;

/**
 获取默认的 attributes
 */
- (NSDictionary *)defaultAttributes;

@end
