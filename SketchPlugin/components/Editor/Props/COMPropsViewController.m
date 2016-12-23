//
//  COMPropsViewController.m
//  components
//
//  Created by 崔明辉 on 2016/12/14.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMPropsViewController.h"
#import "COMPluginController.h"
#import <MCSketchPluginFramework/MCSketchPluginFramework.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <WebKit/WebKit.h>
#import "COMPropsValueObject.h"
#import "COMPropsLayoutObject.h"

@interface COMPropsViewController ()<NSSplitViewDelegate, NSTextFieldDelegate, NSComboBoxDelegate>

@property (nonatomic, strong) COMPropsValueObject *valueObject;
@property (nonatomic, strong) COMPropsLayoutObject *layoutObject;

@property(weak) IBOutlet NSSplitView *splitView;

@end

@implementation COMPropsViewController

+ (void)toggleSidebar {
    static COMPropsViewController *viewController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      viewController = [[COMPropsViewController alloc] init];
      NSString *nibPath = [[[NSBundle bundleForClass:[self class]] bundlePath]
          stringByAppendingString:@"/Contents/Resources/COMPropsViewController.nib"];
      [[[NSNib alloc] initWithNibData:[NSData dataWithContentsOfFile:nibPath] bundle:nil]
          instantiateWithOwner:viewController
               topLevelObjects:nil];
        [viewController createObjects];
    });
    [viewController.valueObject loadLibrary];
    [viewController.valueObject findAvailableClasses];
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
    [view addObserver:viewController forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
    {
        [viewController.view setAlphaValue:1.0];
        [viewController reloadData];
    }
}

#pragma mark - Datas

- (void)createObjects {
    self.valueObject = [COMPropsValueObject new];
    self.valueObject.viewController = self;
    self.classComboBox.delegate = self.valueObject;
    self.tableView.dataSource = self.valueObject;
    self.tableView.delegate = self.valueObject;
    self.layoutObject = [COMPropsLayoutObject new];
    self.layoutObject.viewController = self;
    [[NSNotificationCenter defaultCenter]
     addObserverForName:MCSPluginSelectionDidChangeNotification
     object:nil
     queue:[NSOperationQueue mainQueue]
     usingBlock:^(NSNotification *_Nonnull note) {
         if (Sketch_GetSelectedLayers(Sketch_GetCurrentDocument()).count == 0) {
             [self.view setAlphaValue:0.0];
             return;
         }
         [self.view setAlphaValue:1.0];
         [self reloadData];
     }];
}

- (void)reloadData {
    [self.valueObject loadClass];
    [self.valueObject loadPropsTemplate];
    [self.valueObject loadProps];
    [self.layoutObject loadLayout];
    [self.tableView reloadData];
}

- (IBAction)onLayoutCheckboxChanged:(id)sender {
    [self.layoutObject saveLayout];
}

- (void)controlTextDidEndEditing:(NSNotification *)obj {
    [self.layoutObject saveLayout];
}

- (IBAction)onPublishButtonClicked:(id)sender {
    [[COMPluginController new] showPublisher];
}

- (IBAction)onPropsRefreshButtonClicked:(id)sender {
    [self.valueObject onPropsRefreshButtonClicked:sender];
}

- (IBAction)onPropsDeleteButtonClicked:(id)sender {
    [self.valueObject onPropsDeleteButtonClicked:sender];
}

- (IBAction)onPropsAddButtonClicked:(id)sender {
    [self.valueObject onPropsAddButtonClicked:sender];
}

#pragma mark - Layouts

- (void)viewWillDisappear {
    [super viewWillDisappear];
    [self.view.superview removeObserver:self forKeyPath:@"frame"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor =
        [NSColor colorWithRed:0xe6 / 255.0 green:0xe6 / 255.0 blue:0xe6 / 255.0 alpha:1.0].CGColor;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context {
    [self viewWillLayout];
}

- (void)viewWillLayout {
    [super viewWillLayout];
    self.view.frame =
        NSMakeRect(self.view.superview.frame.size.width - 260, 0, 260.0, self.view.superview.frame.size.height);
    {
        CGRect frame = self.splitView.subviews[0].frame;
        frame.origin.y = 0.0;
        frame.size.height = 64.0;
        self.splitView.subviews[0].frame = frame;
    }
    {
        CGRect frame = self.splitView.subviews[1].frame;
        frame.origin.y = 64.0;
        frame.size.height = self.view.superview.frame.size.height - 440.0 - 38.0 - 64.0;
        self.splitView.subviews[1].frame = frame;
    }
    {
        CGRect frame = self.splitView.subviews[2].frame;
        frame.origin.y = self.splitView.subviews[1].frame.origin.y + self.splitView.subviews[1].frame.size.height;
        frame.size.height = 440.0;
        self.splitView.subviews[2].frame = frame;
    }
    {
        CGRect frame = self.splitView.subviews[3].frame;
        frame.origin.y = self.splitView.subviews[2].frame.origin.y + self.splitView.subviews[2].frame.size.height;
        frame.size.height = 38.0;
        self.splitView.subviews[3].frame = frame;
    }
}

- (NSRect)splitView:(NSSplitView *)splitView
       effectiveRect:(NSRect)proposedEffectiveRect
        forDrawnRect:(NSRect)drawnRect
    ofDividerAtIndex:(NSInteger)dividerIndex {
    return NSZeroRect;
}

- (CGFloat)splitView:(NSSplitView *)splitView
    constrainMinCoordinate:(CGFloat)proposedMinimumPosition
               ofSubviewAt:(NSInteger)dividerIndex {
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

- (CGFloat)splitView:(NSSplitView *)splitView
    constrainMaxCoordinate:(CGFloat)proposedMaximumPosition
               ofSubviewAt:(NSInteger)dividerIndex {
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
    self.layer.backgroundColor =
        [NSColor colorWithRed:0xf9 / 255.0 green:0xf9 / 255.0 blue:0xf9 / 255.0 alpha:1.0].CGColor;
}

@end
