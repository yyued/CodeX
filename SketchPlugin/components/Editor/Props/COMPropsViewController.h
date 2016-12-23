//
//  COMPropsViewController.h
//  components
//
//  Created by 崔明辉 on 2016/12/14.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface COMPropsViewController : NSViewController

@property(weak) IBOutlet NSTableView *tableView;
@property(weak) IBOutlet NSComboBox *classComboBox;
@property(weak) IBOutlet NSSegmentedControl *alignmentRelative;
@property(weak) IBOutlet NSButton *centerHCheckbox;
@property(weak) IBOutlet NSButton *centerVCheckbox;
@property(weak) IBOutlet NSSegmentedControl *sizeRelative;
@property(weak) IBOutlet NSButton *widthCheckbox;
@property(weak) IBOutlet NSTextField *widthTextField;
@property(weak) IBOutlet NSButton *heightCheckbox;
@property(weak) IBOutlet NSTextField *heightTextField;
@property(weak) IBOutlet NSSegmentedControl *pinRelative;
@property(weak) IBOutlet NSButton *topCheckbox;
@property(weak) IBOutlet NSTextField *topTextField;
@property(weak) IBOutlet NSButton *leftCheckbox;
@property(weak) IBOutlet NSTextField *leftTextField;
@property(weak) IBOutlet NSButton *bottomCheckbox;
@property(weak) IBOutlet NSTextField *bottomTextField;
@property(weak) IBOutlet NSButton *rightCheckbox;
@property(weak) IBOutlet NSTextField *rightTextField;

+ (void)toggleSidebar;

@end
