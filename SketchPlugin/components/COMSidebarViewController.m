//
//  COMSidebarViewController.m
//  components
//
//  Created by 崔明辉 on 2016/12/14.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMSidebarViewController.h"
#import <MCSketchPluginFramework/MCSketchPluginFramework.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <WebKit/WebKit.h>

@interface COMSidebarViewController ()<NSSplitViewDelegate, NSTableViewDelegate, NSTableViewDataSource,
                                       NSTextFieldDelegate, NSComboBoxDelegate>

@property(weak) IBOutlet NSSplitView *splitView;
@property(weak) IBOutlet NSTableView *tableView;
@property(weak) IBOutlet NSComboBox *classComboBox;
@property(nonatomic, copy) NSArray *currentProps;

@end

@implementation COMSidebarViewController

+ (void)toggleSidebar {
    static COMSidebarViewController *viewController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      viewController = [[COMSidebarViewController alloc] init];
      NSString *nibPath = [[[NSBundle bundleForClass:[self class]] bundlePath]
          stringByAppendingString:@"/Contents/Resources/COMSidebarViewController.nib"];
      [[[NSNib alloc] initWithNibData:[NSData dataWithContentsOfFile:nibPath] bundle:nil]
          instantiateWithOwner:viewController
               topLevelObjects:nil];
      [[NSNotificationCenter defaultCenter]
          addObserverForName:MCSPluginSelectionDidChangeNotification
                      object:nil
                       queue:[NSOperationQueue mainQueue]
                  usingBlock:^(NSNotification *_Nonnull note) {
                    if (Sketch_GetSelectedLayers(Sketch_GetCurrentDocument()).count == 0) {
                        [viewController.view setAlphaValue:0.0];
                        return;
                    }
                    [viewController.view setAlphaValue:1.0];
                    [viewController loadClass];
                    [viewController loadProps];
                    [viewController.tableView reloadData];
                  }];
        [viewController loadLibrary];
        [viewController findAvailableClasses];
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
    [view addObserver:viewController forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
}

static JSContext *context;
static WebView *webView;

- (void)loadLibrary {
    webView = [WebView new];
    context = webView.mainFrame.javaScriptContext;
    NSString *libraryPath = [[NSUserDefaults standardUserDefaults] valueForKey:@"com.yy.ued.sketch.components.libPath"];
    if (libraryPath == nil) {
        return;
    }
    for (NSString *dirName in [[NSFileManager defaultManager] enumeratorAtPath:libraryPath]) {
        NSString *subPath = [libraryPath stringByAppendingFormat:@"/%@", dirName];
        for (NSString *fileName in [[NSFileManager defaultManager] enumeratorAtPath:subPath]) {
            if ([fileName hasSuffix:@".js"]) {
                NSString *filePath = [subPath stringByAppendingFormat:@"/%@", fileName];
                NSString *fileContents =
                    [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
                if (fileContents != nil) {
                    [context evaluateScript:fileContents];
                }
            }
        }
    }
}

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

#pragma mark - NSSplitViewDelegate

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

#pragma mark - NSTableViewDelegate, NSTableViewDataSource

- (void)loadProps {
    MSLayer *layer = [Sketch_GetSelectedLayers(Sketch_GetCurrentDocument()) firstObject];
    if (layer != nil) {
        NSMutableArray *currentProps = [NSMutableArray array];
        NSDictionary *dict = [[MSPluginCommand_Class new] valueForKey:@"props"
                                                              onLayer:layer
                                                  forPluginIdentifier:@"com.yy.ued.sketch.components"];
        if ([dict isKindOfClass:[NSDictionary class]]) {
            [dict enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
              if ([key hasPrefix:@"_"]) {
                  return;
              }
              [currentProps addObject:@{
                  @"key" : key,
                  @"value" : obj,
                  @"type" : dict[[NSString stringWithFormat:@"_%@", key]] != nil
                                ? dict[[NSString stringWithFormat:@"_%@", key]]
                                : @"String",
              }];
            }];
        }
        self.currentProps = currentProps;
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.currentProps.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row < self.currentProps.count) {
        NSDictionary *item = self.currentProps[row];
        if ([tableColumn.identifier isEqualToString:@"Key"]) {
            NSTextField *view = [[NSTextField alloc] initWithFrame:NSMakeRect(0, -5, 200, 22)];
            view.accessibilityIdentifier = @"Key";
            view.tag = row;
            view.maximumNumberOfLines = 1;
            view.drawsBackground = NO;
            view.bordered = NO;
            [view setStringValue:@"Key"];
            [view setStringValue:item[@"key"]];
            view.delegate = self;
            return view;
        }
        if ([tableColumn.identifier isEqualToString:@"Value"]) {
            if ([item[@"type"] isEqualToString:@"String"] || [item[@"type"] isEqualToString:@"Number"]) {
                NSTextField *view = [[NSTextField alloc] initWithFrame:NSMakeRect(0, -5, 200, 22)];
                view.accessibilityIdentifier = @"Value";
                view.tag = row;
                view.maximumNumberOfLines = 1;
                view.drawsBackground = NO;
                view.bordered = NO;
                if ([item[@"value"] isKindOfClass:[NSString class]]) {
                    [view setStringValue:item[@"value"]];
                } else if ([item[@"value"] isKindOfClass:[NSNumber class]]) {
                    [view setStringValue:[NSString stringWithFormat:@"%@", item[@"value"]]];
                }
                view.delegate = self;
                return view;
            } else if ([item[@"type"] isEqualToString:@"Bool"]) {
                NSButton *checkbox = [NSButton checkboxWithTitle:@"True" target:self action:@selector(saveProps:)];
                checkbox.accessibilityIdentifier = @"Value";
                checkbox.tag = row;
                if ([item[@"value"] isKindOfClass:[NSNumber class]]) {
                    checkbox.state = [item[@"value"] boolValue] ? 1 : 0;
                } else {
                    checkbox.state = 0;
                }
                checkbox.frame = NSMakeRect(0, 0, 200, 22);
                return checkbox;
            } else if ([item[@"type"] isEqualToString:@"Enum"]) {
                NSPopUpButton *view = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(0, 0, 88, 27)];
                view.accessibilityIdentifier = @"Value";
                view.tag = row;
                view.bordered = NO;
                [view addItemsWithTitles:@[
                    @"Option1",
                    @"Option2",
                    @"Option3",
                    @"Option4",
                ]];
                [view setTarget:self];
                [view setAction:@selector(saveProps:)];
                return view;
            }
        }
        if ([tableColumn.identifier isEqualToString:@"Type"]) {
            NSPopUpButton *view = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(-5, -5, 86, 27)];
            view.accessibilityIdentifier = @"Type";
            view.tag = row;
            [view addItemsWithTitles:@[
                @"String",
                @"Number",
                @"Bool",
                @"Enum",
            ]];
            [view selectItemWithTitle:item[@"type"]];
            [view setTarget:self];
            [view setAction:@selector(saveProps:)];
            return view;
        }
    }
    return [NSView new];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 22.0;
}

- (IBAction)onPropsRefreshButtonClicked:(id)sender {
    NSString *className = self.classComboBox.stringValue;
    if (className != nil) {
        NSDictionary *defaultProps = [[context[className][@"defaultProps"] callWithArguments:@[]] toDictionary];
        NSMutableArray *currentProps = [NSMutableArray array];
        [defaultProps enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
          if ([obj isKindOfClass:[NSDictionary class]] && obj[@"type"] != nil) {
              [currentProps addObject:@{
                  @"key" : key,
                  @"value" : obj[@"value"] != nil ? [NSString stringWithFormat:@"%@", obj[@"value"]] : @"",
                  @"type" : obj[@"type"],
              }];
          }
        }];
        self.currentProps = currentProps;
        [self.tableView reloadData];
        [self savePropsToCurrentLayer];
    }
}

- (IBAction)onPropsDeleteButtonClicked:(id)sender {
    NSMutableArray *newProps = [NSMutableArray array];
    [self.currentProps enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
      if ([self.tableView.selectedRowIndexes containsIndex:idx]) {
          return;
      }
      [newProps addObject:obj];
    }];
    self.currentProps = newProps;
    [self.tableView reloadData];
    [self savePropsToCurrentLayer];
}

- (IBAction)onPropsAddButtonClicked:(id)sender {
    NSMutableArray *currentProps = [self.currentProps mutableCopy];
    [currentProps addObject:@{
        @"key" : @"Key",
        @"value" : @"Value",
        @"type" : @"String",
    }];
    self.currentProps = currentProps;
    [self.tableView reloadData];
    [self savePropsToCurrentLayer];
}

- (void)controlTextDidEndEditing:(NSNotification *)obj {
    [self saveClass];
    [self saveProps:obj.object];
}

- (void)saveProps:(NSView *)sender {
    if (sender.tag < self.currentProps.count) {
        NSMutableDictionary *dict = [self.currentProps[sender.tag] mutableCopy];
        if ([sender.accessibilityIdentifier isEqualToString:@"Key"]) {
            dict[@"key"] = [(NSTextField *)sender stringValue];
        } else if ([sender.accessibilityIdentifier isEqualToString:@"Value"]) {
            if ([sender isKindOfClass:[NSTextField class]]) {
                if ([dict[@"type"] isEqualToString:@"String"]) {
                    dict[@"value"] = [(NSTextField *)sender stringValue];
                } else if ([dict[@"type"] isEqualToString:@"Number"]) {
                    dict[@"value"] = [[NSNumberFormatter new] numberFromString:[(NSTextField *)sender stringValue]];
                }
            } else if ([sender isKindOfClass:[NSButton class]]) {
                if ([dict[@"type"] isEqualToString:@"Bool"]) {
                    dict[@"value"] = [(NSButton *)sender state] == 1 ? @(YES) : @(NO);
                }
            }
        } else if ([sender.accessibilityIdentifier isEqualToString:@"Type"]) {
            dict[@"type"] = [[(NSPopUpButton *)sender selectedItem] title];
        }
        NSMutableArray *currentProps = [self.currentProps mutableCopy];
        [currentProps setObject:[dict copy] atIndexedSubscript:sender.tag];
        self.currentProps = currentProps;
        if ([sender.accessibilityIdentifier isEqualToString:@"Type"]) {
            [self.tableView reloadData];
        }
        [self savePropsToCurrentLayer];
    }
}

- (void)savePropsToCurrentLayer {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [self.currentProps enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
      dict[obj[@"key"]] = obj[@"value"];
      dict[[NSString stringWithFormat:@"_%@", obj[@"key"]]] = obj[@"type"];
    }];
    [Sketch_GetSelectedLayers(Sketch_GetCurrentDocument())
        enumerateObjectsUsingBlock:^(id _Nonnull layer, NSUInteger idx, BOOL *_Nonnull stop) {
          [[MSPluginCommand_Class new] setValue:[dict copy]
                                         forKey:@"props"
                                        onLayer:layer
                            forPluginIdentifier:@"com.yy.ued.sketch.components"];
        }];
}

#pragma mark - Class

- (void)findAvailableClasses {
    [self.classComboBox removeAllItems];
    NSArray *keys = [[context evaluateScript:@"Object.keys(window)"] toArray];
    [keys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[context[obj][@"defaultProps"] callWithArguments:@[]] toDictionary] != nil) {
            [self.classComboBox addItemWithObjectValue:obj];
        }
    }];
}

- (void)loadClass {
    MSLayer *layer = [Sketch_GetSelectedLayers(Sketch_GetCurrentDocument()) firstObject];
    if (layer != nil) {
        NSString *className = [[MSPluginCommand_Class new] valueForKey:@"class"
                                                               onLayer:layer
                                                   forPluginIdentifier:@"com.yy.ued.sketch.components"];
        self.classComboBox.stringValue = className != nil ? className : @"";
    }
}

- (void)saveClass {
    if (self.classComboBox.stringValue != nil) {
        [Sketch_GetSelectedLayers(Sketch_GetCurrentDocument())
            enumerateObjectsUsingBlock:^(id _Nonnull layer, NSUInteger idx, BOOL *_Nonnull stop) {
              [[MSPluginCommand_Class new] setValue:self.classComboBox.stringValue
                                             forKey:@"class"
                                            onLayer:layer
                                forPluginIdentifier:@"com.yy.ued.sketch.components"];
            }];
    }
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
