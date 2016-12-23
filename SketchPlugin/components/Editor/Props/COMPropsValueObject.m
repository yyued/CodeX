//
//  COMPropsValueObject.m
//  components
//
//  Created by 崔明辉 on 2016/12/23.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMPropsValueObject.h"
#import <MCSketchPluginFramework/MCSketchPluginFramework.h>

@implementation COMPropsValueObject

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

- (void)loadPropsTemplate {
    NSString *className = self.viewController.classComboBox.stringValue;
    if (className != nil) {
        NSDictionary *defaultProps = [[context[className][@"defaultProps"] callWithArguments:@[]] toDictionary];
        self.currentPropsTemplate = defaultProps;
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.currentProps.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row < self.currentProps.count) {
        NSDictionary *item = self.currentProps[row];
        if ([tableColumn.identifier isEqualToString:@"Key"]) {
            NSTextField *view = [[NSTextField alloc] initWithFrame:NSZeroRect];
            [view setPreferredMaxLayoutWidth:300];
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
                NSTextField *view = [[NSTextField alloc] initWithFrame:NSZeroRect];
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
                NSPopUpButton *view = [[NSPopUpButton alloc] initWithFrame:NSZeroRect];
                view.accessibilityIdentifier = @"Value";
                view.tag = row;
                view.bordered = NO;
                if ([self.currentPropsTemplate[item[@"key"]][@"value"] isKindOfClass:[NSArray class]]) {
                    [view addItemsWithTitles:self.currentPropsTemplate[item[@"key"]][@"value"]];
                    if ([item[@"value"] isKindOfClass:[NSString class]]) {
                        [view selectItemWithTitle:item[@"value"]];
                    }
                    else {
                        [view selectItemWithTitle:[self.currentPropsTemplate[item[@"key"]][@"value"] firstObject]];
                    }
                }
                else if ([item[@"value"] isKindOfClass:[NSString class]]) {
                    [view addItemsWithTitles:@[ item[@"value"] ]];
                    [view selectItemWithTitle:item[@"value"]];
                }
                [view setTarget:self];
                [view setAction:@selector(saveProps:)];
                return view;
            } else if ([item[@"type"] isEqualToString:@"Layer"]) {
                NSPopUpButton *view = [[NSPopUpButton alloc] initWithFrame:NSZeroRect];
                view.accessibilityIdentifier = @"Value";
                view.tag = row;
                view.bordered = NO;
                NSMutableArray *layersName = [NSMutableArray array];
                for (MSLayer *sublayer in Sketch_GetSelectedLayers(Sketch_GetCurrentDocument())) {
                    [layersName addObject:sublayer.name];
                }
                if ([item[@"value"] isKindOfClass:[NSString class]]) {
                    if (![layersName containsObject:item[@"value"]]) {
                        [layersName addObject:item[@"value"]];
                    }
                    [view addItemsWithTitles:layersName];
                    [view selectItemWithTitle:item[@"value"]];
                }
                else {
                    [view addItemsWithTitles:layersName];
                }
                [view setTarget:self];
                [view setAction:@selector(saveProps:)];
                return view;
            }
        }
        if ([tableColumn.identifier isEqualToString:@"Type"]) {
            NSPopUpButton *view = [[NSPopUpButton alloc] initWithFrame:NSZeroRect];
            view.accessibilityIdentifier = @"Type";
            view.tag = row;
            view.bordered = NO;
            [view addItemsWithTitles:@[
                                       @"String",
                                       @"Number",
                                       @"Bool",
                                       @"Enum",
                                       @"Layer",
                                       ]];
            [view selectItemWithTitle:item[@"type"]];
            [view setTarget:self];
            [view setAction:@selector(saveProps:)];
            view.enabled = self.currentPropsTemplate[item[@"key"]] == nil;
            return view;
        }
    }
    return [NSView new];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 18.0;
}

- (IBAction)onPropsRefreshButtonClicked:(id)sender {
    [self loadPropsTemplate];
    NSString *className = self.viewController.classComboBox.stringValue;
    if (className != nil) {
        NSDictionary *defaultProps = [[context[className][@"defaultProps"] callWithArguments:@[]] toDictionary];
        NSMutableArray *currentProps = [NSMutableArray array];
        [defaultProps enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]] && obj[@"type"] != nil) {
                [currentProps addObject:@{
                                          @"key" : key,
                                          @"value" : obj[@"value"] != nil ? obj[@"value"] : @"",
                                          @"type" : obj[@"type"],
                                          }];
            }
        }];
        self.currentProps = currentProps;
        [self.viewController.tableView reloadData];
        [self savePropsToCurrentLayer];
    }
}

- (IBAction)onPropsDeleteButtonClicked:(id)sender {
    NSMutableArray *newProps = [NSMutableArray array];
    [self.currentProps enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([self.viewController.tableView.selectedRowIndexes containsIndex:idx]) {
            return;
        }
        [newProps addObject:obj];
    }];
    self.currentProps = newProps;
    [self.viewController.tableView reloadData];
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
    [self.viewController.tableView reloadData];
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
            } else if ([sender isKindOfClass:[NSPopUpButton class]]) {
                if ([dict[@"type"] isEqualToString:@"Enum"]) {
                    dict[@"value"] = [[(NSPopUpButton *)sender selectedItem] title];
                }
                else if ([dict[@"type"] isEqualToString:@"Layer"]) {
                    dict[@"value"] = [[(NSPopUpButton *)sender selectedItem] title];
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
            [self.viewController.tableView reloadData];
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

- (void)findAvailableClasses {
    [self.viewController.classComboBox removeAllItems];
    NSArray *keys = [[context evaluateScript:@"Object.keys(window)"] toArray];
    [keys enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([[context[obj][@"defaultProps"] callWithArguments:@[]] toDictionary] != nil) {
            [self.viewController.classComboBox addItemWithObjectValue:obj];
        }
    }];
}

- (void)loadClass {
    MSLayer *layer = [Sketch_GetSelectedLayers(Sketch_GetCurrentDocument()) firstObject];
    if (layer != nil) {
        NSString *className = [[MSPluginCommand_Class new] valueForKey:@"class"
                                                               onLayer:layer
                                                   forPluginIdentifier:@"com.yy.ued.sketch.components"];
        self.viewController.classComboBox.stringValue = className != nil ? className : @"";
    }
}

- (void)saveClass {
    if (self.viewController.classComboBox.stringValue != nil) {
        [Sketch_GetSelectedLayers(Sketch_GetCurrentDocument())
         enumerateObjectsUsingBlock:^(id _Nonnull layer, NSUInteger idx, BOOL *_Nonnull stop) {
             [[MSPluginCommand_Class new] setValue:self.viewController.classComboBox.stringValue
                                            forKey:@"class"
                                           onLayer:layer
                               forPluginIdentifier:@"com.yy.ued.sketch.components"];
         }];
    }
}

@end
