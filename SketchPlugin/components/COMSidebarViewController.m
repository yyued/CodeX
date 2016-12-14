//
//  COMSidebarViewController.m
//  components
//
//  Created by 崔明辉 on 2016/12/14.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMSidebarViewController.h"

@interface COMSidebarViewController ()<NSSplitViewDelegate, NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSSplitView *splitView;

@end

@implementation COMSidebarViewController

+ (void)toggleSidebar {
    static COMSidebarViewController *viewController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        viewController = [[COMSidebarViewController alloc] init];
        NSString *nibPath = [[[NSBundle bundleForClass:[self class]] bundlePath]
                             stringByAppendingString:@"/Contents/Resources/COMSidebarViewController.nib"];
        [[[NSNib alloc] initWithNibData:[NSData dataWithContentsOfFile:nibPath] bundle:nil] instantiateWithOwner:viewController
                                                                                                 topLevelObjects:nil];
    });
    NSView *view = [[[[[NSApplication sharedApplication] mainWindow] contentView] subviews][0] subviews][1];
    {
        view.wantsLayer = YES;
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, 1, 1);
        layer.backgroundColor = [NSColor clearColor].CGColor;
        [view.layer addSublayer:layer];
    }
    viewController.view.frame = NSMakeRect(0, 0, 100, 100);
    [view addSubview:viewController.view];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.wantsLayer = YES;
    {
        self.view.layer.backgroundColor = [NSColor colorWithRed:0xe6/255.0 green:0xe6/255.0 blue:0xe6/255.0 alpha:1.0].CGColor;
        CGRect frame = self.splitView.subviews[0].frame;
        frame.size.height = 64.0;
        self.splitView.subviews[0].frame = frame;
    }
    {
        self.view.layer.backgroundColor = [NSColor colorWithRed:0xe6/255.0 green:0xe6/255.0 blue:0xe6/255.0 alpha:1.0].CGColor;
        CGRect frame = self.splitView.subviews[2].frame;
        frame.size.height = 440.0;
        self.splitView.subviews[2].frame = frame;
    }
    {
        self.view.layer.backgroundColor = [NSColor colorWithRed:0xe6/255.0 green:0xe6/255.0 blue:0xe6/255.0 alpha:1.0].CGColor;
        CGRect frame = self.splitView.subviews[3].frame;
        frame.size.height = 38.0;
        self.splitView.subviews[3].frame = frame;
    }
    
}

- (void)viewWillLayout {
    [super viewWillLayout];
    self.view.frame = NSMakeRect(self.view.superview.frame.size.width - 260, 0, 260.0, self.view.superview.frame.size.height);
}

#pragma mark - NSSplitViewDelegate

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if (dividerIndex == 0) {
        return 64.0;
    }
    if (dividerIndex == 2) {
        return 440.0;
    }
    if (dividerIndex == 3) {
        return 38.0;
    }
    return 0.0;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if (dividerIndex == 0) {
        return 64.0;
    }
    if (dividerIndex == 2) {
        return 440.0;
    }
    if (dividerIndex == 3) {
        return 38.0;
    }
    return CGFLOAT_MAX;
}

#pragma mark - NSTableViewDelegate, NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return 100;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    return [[NSTableRowView alloc] init];
}

@end

@interface COMClearView : NSView

@end

@implementation COMClearView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.wantsLayer = YES;
}

- (BOOL)wantsUpdateLayer {
    return YES;
}

- (void)updateLayer {
    self.layer.backgroundColor = [NSColor colorWithRed:0xf9/255.0 green:0xf9/255.0 blue:0xf9/255.0 alpha:1.0].CGColor;
}

@end
