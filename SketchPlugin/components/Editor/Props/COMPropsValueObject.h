//
//  COMPropsValueObject.h
//  components
//
//  Created by 崔明辉 on 2016/12/23.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "COMPropsViewController.h"

@interface COMPropsValueObject : NSObject <NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate, NSComboBoxDelegate>

@property (nonatomic, weak) COMPropsViewController *viewController;
@property(nonatomic, copy) NSArray *currentProps;
@property(nonatomic, copy) NSDictionary *currentPropsTemplate;

- (void)loadLibrary;
- (void)loadClass;
- (void)loadProps;
- (void)loadPropsTemplate;
- (void)findAvailableClasses;
- (IBAction)onPropsRefreshButtonClicked:(id)sender;
- (IBAction)onPropsDeleteButtonClicked:(id)sender;
- (IBAction)onPropsAddButtonClicked:(id)sender;

@end
