//
//  CollectionViewItem.m
//  NSCollectionCodeView
//
//  Created by zhaojw on 15/8/28.
//  Copyright (c) 2015年 zhaojw. All rights reserved.
//

#import <MCSketchPluginFramework/MCSketchPluginFramework.h>
#import "COMComponentCollectionViewItem.h"
#import "COMComponentEntity.h"

@interface COMComponentCollectionViewItem ()

@end

@implementation COMComponentCollectionViewItem

- (void)loadView {
    NSView *view = [NSView new];
    [view setWantsLayer:YES];
    [view.layer addSublayer:self.selectedLayer];
    view.frame = NSMakeRect(0, 0, 88, 88);
    [view addSubview:self.titleView];
    [view addSubview:self.iconImageView];
    NSGestureRecognizer *clickGesture = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(onClick)];
    [view addGestureRecognizer:clickGesture];
    NSClickGestureRecognizer *dbclickGesture = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleClick)];
    dbclickGesture.numberOfClicksRequired = 2;
    [view addGestureRecognizer:dbclickGesture];
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleView.string = @"";
}

- (void)onClick {
    [[self.collectionView visibleItems] enumerateObjectsUsingBlock:^(NSCollectionViewItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[(COMComponentCollectionViewItem *)obj selectedLayer] setHidden:YES];
    }];
    self.selectedLayer.hidden = NO;
}

- (void)onDoubleClick {
    [[NSApplication sharedApplication] endModalSession:self.modalWindowController.modalSession];
    [self.modalWindowController close];
    if (self.modalWindowController.replacing) {
        [self replaceLayer];
    }
    else {
        [self addLayer];
    }
}

- (void)addLayer {
    if ([[self representedObject] componentLayer] == nil || ![[[self representedObject] componentLayer] isKindOfClass:MSLayer_Class]) {
        return;
    }
    if ([[MSDocument_Class currentDocument] selectedLayers].count > 0) {
        MSLayer *newLayer = [[[self representedObject] componentLayer] duplicate];
        [newLayer removeFromParent];
        MSLayerGroup *firstLayer = [[MSDocument_Class currentDocument] selectedLayers].firstObject;
        if ([firstLayer isKindOfClass:MSLayerGroup_Class]) {
            [firstLayer addLayers:@[newLayer]];
            MSRect *newRect = [MSRect_Class new];
            [newRect setX:(firstLayer.frame.width - newLayer.frame.width) / 2.0];
            [newRect setY:(firstLayer.frame.height - newLayer.frame.height) / 2.0];
            [newRect setWidth:newLayer.frame.width];
            [newRect setHeight:newLayer.frame.height];
            [newLayer setFrame:newRect];
            return;
        }
    }
    if ([[[MSDocument_Class currentDocument] currentPage] currentArtboard] != nil) {
        MSLayer *newLayer = [[[self representedObject] componentLayer] duplicate];
        [newLayer removeFromParent];
        [[[[MSDocument_Class currentDocument] currentPage] currentArtboard] insertLayers:@[newLayer] atIndex:0];
    }
    else {
        MSLayer *newLayer = [[[self representedObject] componentLayer] duplicate];
        [newLayer removeFromParent];
        [[[[MSDocument_Class currentDocument] currentPage] artboards].firstObject insertLayers:@[newLayer] atIndex:0];
    }
}

- (void)replaceLayer {
    if ([[self representedObject] componentLayer] == nil || ![[[self representedObject] componentLayer] isKindOfClass:MSLayer_Class]) {
        return;
    }
    if ([[MSDocument_Class currentDocument] selectedLayers].count > 0) {
        for (MSLayer *layer in [[MSDocument_Class currentDocument] selectedLayers]) {
            MSLayer *newLayer = [[[self representedObject] componentLayer] duplicate];
            [newLayer removeFromParent];
            [[layer parentGroup] insertLayers:@[newLayer] afterLayer:layer];
            [newLayer setFrame:[layer frame]];
            [layer removeFromParent];
        }
    }
}

- (COMComponentEntity *)representedObject {
    if (![[super representedObject] isKindOfClass:[COMComponentEntity class]]) {
        return nil;
    }
    return [super representedObject];
}

- (CALayer *)selectedLayer {
    if (_selectedLayer == nil) {
        _selectedLayer = [CALayer layer];
        _selectedLayer.frame = CGRectMake(0, 0, 88, 88);
        _selectedLayer.backgroundColor = [NSColor colorWithWhite:0.0 alpha:0.05].CGColor;
        _selectedLayer.hidden = YES;
        _selectedLayer.cornerRadius = 6.0;
    }
    return _selectedLayer;
}

- (NSImageView *)iconImageView {
    if (_iconImageView == nil) {
        _iconImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 33, 88, 33)];
    }
    return _iconImageView;
}

- (NSTextView *)titleView {
    if (_titleView == nil) {
        _titleView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 88, 22)];
        _titleView.backgroundColor = [NSColor clearColor];
        _titleView.font = [NSFont systemFontOfSize:14.0];
        _titleView.textColor = [NSColor blackColor];
        _titleView.alignment = NSTextAlignmentCenter;
        _titleView.editable = NO;
        _titleView.selectable = NO;
    }
    return _titleView;
}

@end
