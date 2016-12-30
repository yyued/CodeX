//
//  COMCloudWindowController.m
//  components
//
//  Created by 崔明辉 on 2016/12/30.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMCloudWindowController.h"
#import "COMCloudComponentEntity.h"
#import "COMCloudOperator.h"

@interface COMCloudWindowController () <NSTableViewDelegate, NSTableViewDataSource, NSWindowDelegate, NSTextFieldDelegate>

@property (copy) NSArray<COMCloudComponentEntity *> *items;
@property (strong) NSMutableDictionary *selectedItems;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *specTextField;

@end

@implementation COMCloudWindowController

+ (instancetype) new {
    COMCloudWindowController *obj = [[COMCloudWindowController alloc] init];
    NSString *nibPath = [[[NSBundle bundleForClass:[self class]] bundlePath]
                         stringByAppendingString:@"/Contents/Resources/COMCloudWindowController.nib"];
    [[[NSNib alloc] initWithNibData:[NSData dataWithContentsOfFile:nibPath] bundle:nil] instantiateWithOwner:obj
                                                                                             topLevelObjects:nil];
    return obj;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.50 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"com.yy.ued.sketch.components.specPath"] != nil) {
            [self.specTextField setStringValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"com.yy.ued.sketch.components.specPath"]];
        }
        [self loadSpec];
    });
}

- (BOOL)windowShouldClose:(id)sender {
    [[NSApplication sharedApplication] endModalSession:self.modalSession];
    [self.window close];
    return YES;
}

- (IBAction)onSearchButtonClicked:(id)sender {
    [self loadSpec];
}

- (void)controlTextDidEndEditing:(NSNotification *)obj {
    [[NSUserDefaults standardUserDefaults] setValue:self.specTextField.stringValue forKey:@"com.yy.ued.sketch.components.specPath"];
}

- (void)loadSpec {
    NSString *specPath = self.specTextField.stringValue;
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:specPath] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data != nil) {
            NSArray *components = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSMutableArray *items = [NSMutableArray array];
            if ([components isKindOfClass:[NSArray class]]) {
                [components enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    COMCloudComponentEntity *item = [COMCloudComponentEntity new];
                    item.name = obj[@"name"];
                    item.author = obj[@"author"];
                    item.version = obj[@"version"];
                    item.desc = obj[@"description"];
                    item.zip = obj[@"zip"];
                    item.dependencies = obj[@"dependencies"];
                    [items addObject:item];
                }];
                self.items = items;
                self.selectedItems = [NSMutableDictionary dictionary];
                [self.tableView reloadData];
            }
        }
    }] resume];
}

#pragma mark - NSTableViewDelegate, NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.items.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row < self.items.count) {
        COMCloudComponentEntity *item = self.items[row];
        if ([tableColumn.identifier isEqualToString:@"name"]) {
            NSTextView *view = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 0, 22)];
            view.font = [NSFont systemFontOfSize:14.0];
            view.editable = NO;
            view.selectable = NO;
            [view setString:item.name];
            return view;
        }
        if ([tableColumn.identifier isEqualToString:@"description"]) {
            NSTextView *view = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 0, 22)];
            view.font = [NSFont systemFontOfSize:14.0];
            view.editable = NO;
            view.selectable = NO;
            [view setString:item.desc];
            return view;
        }
        if ([tableColumn.identifier isEqualToString:@"download"]) {
            NSButton *button = [NSButton checkboxWithTitle:@" " target:self action:@selector(onSelect:)];
            button.frame = NSMakeRect(0, 0, 0, 22);
            button.tag = row;
            return button;
        }
    }
    return [NSView new];
}

- (void)onSelect:(NSButton *)sender {
    self.selectedItems[@(sender.tag)] = sender.state == 1 ? @(YES) : @(NO);
}

- (IBAction)onDownload:(id)sender {
    [self.selectedItems enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj boolValue]) {
            [COMCloudOperator addComponent:self.items[[key integerValue]] completionBlock:nil];
        }
    }];
    [[NSApplication sharedApplication] endModalSession:self.modalSession];
    [self close];
}

@end
