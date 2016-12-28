//
//  COMPropsLayoutObject.h
//  components
//
//  Created by 崔明辉 on 2016/12/23.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "COMPropsViewController.h"

@interface COMPropsLayoutObject : NSObject

@property (nonatomic, weak) COMPropsViewController *viewController;

- (void)loadLayout;

- (void)autofillWidth;

- (void)autofillHeight;

- (void)autofillTop;

- (void)autofillLeft;

- (void)autofillBottom;

- (void)autofillRight;

- (void)saveLayout;

@end
