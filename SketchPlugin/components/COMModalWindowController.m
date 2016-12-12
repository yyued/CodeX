//
//  COMModalWindowController.m
//  components
//
//  Created by 崔明辉 on 2016/12/7.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMModalWindowController.h"
#import "COMComponentCollectionViewItem.h"
#import "COMSourceEntity.h"

@interface COMModalWindowController ()<NSCollectionViewDataSource, NSCollectionViewDelegate, NSOutlineViewDelegate, NSOutlineViewDataSource>

@property (nonatomic, copy) NSArray<COMSourceEntity *> *sources;
@property (nonatomic, copy) NSArray<NSString *> *categories;
@property (nonatomic, strong) NSString *currentFilter;
@property (nonatomic, strong) COMSourceEntity *currentSource;

@end

@implementation COMModalWindowController

+ (instancetype) new {
    COMModalWindowController *obj = [[COMModalWindowController alloc] init];
    NSString *nibPath = [[[NSBundle bundleForClass:[self class]] bundlePath]
        stringByAppendingString:@"/Contents/Resources/COMModalWindowController.nib"];
    [[[NSNib alloc] initWithNibData:[NSData dataWithContentsOfFile:nibPath] bundle:nil] instantiateWithOwner:obj
                                                                                             topLevelObjects:nil];
    return obj;
}

- (void)setReplacing:(BOOL)replacing {
    _replacing = replacing;
    self.window.title = replacing ? @"Replace" : @"Insert";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      self.collectionView.delegate = self;
      self.collectionView.dataSource = self;
      self.outlineView.delegate = self;
      self.outlineView.dataSource = self;
      [self.collectionView registerClass:[COMComponentCollectionViewItem class] forItemWithIdentifier:@"Cell"];
      [self requestSources];
    });
}

- (void)cancelOperation:(id)sender {
    [self handleCloseButtonClicked:nil];
}

- (IBAction)handleCloseButtonClicked:(id)sender {
    [[NSApplication sharedApplication] endModalSession:self.modalSession];
    [self.window close];
}

#pragma mark - NSCollectionView DataSource & Delegate

- (NSView *)collectionView:(NSCollectionView *)collectionView
    viewForSupplementaryElementOfKind:(NSString *)kind
                          atIndexPath:(NSIndexPath *)indexPath {
    NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 300, 44)];
    return view;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self filteredComponents].count;
}

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return 1;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView
     itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    COMComponentCollectionViewItem *item = [collectionView makeItemWithIdentifier:@"Cell" forIndexPath:indexPath];
    item.modalWindowController = self;
    if (indexPath.item < [self filteredComponents].count) {
        COMComponentEntity *componentItem = [self filteredComponents][indexPath.item];
        item.representedObject = componentItem;
        item.titleView.string = componentItem.componentName;
        item.iconImageView.image = componentItem.iconImage;
    }
    return item;
}

- (NSArray *)filteredComponents {
    if (self.currentFilter == nil) {
        return self.currentSource.components;
    }
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(COMComponentEntity * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject.componentName hasPrefix:self.currentFilter];
    }];
    return [self.currentSource.components filteredArrayUsingPredicate:predicate];
}

#pragma mark - NSOutlineView DataSource & Delegate

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return self.categories.count;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (index < self.categories.count) {
        return self.categories[index];
    }
    return nil;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if ([item isKindOfClass:[NSString class]]) {
        return item;
    }
    return nil;
}

- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item {
    NSTableRowView *rowView = [[NSTableRowView alloc] initWithFrame:CGRectMake(0, 0, 130, 24)];
    NSTextField *textView = [[NSTextField alloc] initWithFrame:CGRectMake(12, 4, 130, 16)];
    [textView setBackgroundColor:[NSColor clearColor]];
    [textView setStringValue:item];
    textView.editable = NO;
    textView.selectable = NO;
    textView.bezeled = NO;
    textView.bezeled = NO;
    textView.drawsBackground = NO;
    [rowView addSubview:textView];
    return rowView;
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
    return 24;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    if ([self.outlineView selectedRow] < self.categories.count) {
        self.currentFilter = self.categories[[self.outlineView selectedRow]];
        [self.collectionView reloadData];
    }
}

#pragma mark - Data Fetcher

- (void)requestSources {
    if (MSDocument_Class != NULL) {
        [self fetchSketchSources];
    } else {
        [self fetchMockSources];
    }
    [self.sourceMenu removeAllItems];
    [self.sources enumerateObjectsUsingBlock:^(COMSourceEntity *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
      NSMenuItem *menuItem =
          [[NSMenuItem alloc] initWithTitle:obj.sourceName action:@selector(onSourceChanged:) keyEquivalent:@""];
      menuItem.tag = idx;
      [self.sourceMenu addItem:menuItem];
    }];
    self.currentSource = self.sources.firstObject;
    self.currentFilter = nil;
    [self.collectionView reloadData];
    NSMutableArray *categoires = [NSMutableArray array];
    [self.currentSource.components enumerateObjectsUsingBlock:^(COMComponentEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *prefix = [obj.componentName componentsSeparatedByString:@"/"].firstObject;
        if (![categoires containsObject:prefix]) {
            [categoires addObject:prefix];
        }
    }];
    self.categories = categoires;
    [self.outlineView reloadData];
}

- (void)fetchSketchSources {
    NSArray<MSPage *> *pages = [[MSDocument_Class currentDocument] pages];
    NSMutableArray<COMSourceEntity *> *items = [NSMutableArray array];
    [pages enumerateObjectsUsingBlock:^(MSPage *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
      if ([obj.name hasPrefix:@"TPL - "]) {
          COMSourceEntity *item = [COMSourceEntity new];
          item.sourceName = [obj.name stringByReplacingOccurrencesOfString:@"TPL - " withString:@""];
          NSMutableArray<COMComponentEntity *> *components = [NSMutableArray array];
          for (MSLayerGroup *layer in [[obj artboards].firstObject layers]) {
              if ([layer isKindOfClass:MSLayerGroup_Class]) {
                  COMComponentEntity *componentItem = [COMComponentEntity new];
                  componentItem.componentName = [layer name];
                  componentItem.iconImage = [self snapImageWithLayer:layer];
                  componentItem.componentLayer = layer;
                  [components addObject:componentItem];
              }
          }
          item.components = components;
          [items addObject:item];
      }
    }];
    self.sources = items;
}

- (NSImage *)snapImageWithLayer:(MSLayer *)layer {
    MSExportRequest *request = [[MSExportRequest_Class exportRequestsFromExportableLayer:layer] firstObject];
    NSString *snapImageFileKey =
        [NSString stringWithFormat:@"/tmp/com.yy.ued.sketch.components/.snap.%@.png",
                                   [layer.name stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
    [[MSDocument_Class currentDocument] saveArtboardOrSlice:request toFile:snapImageFileKey];
    return [[NSImage alloc] initWithContentsOfFile:snapImageFileKey];
}

- (void)fetchMockSources {
    COMSourceEntity *item = [COMSourceEntity new];
    item.sourceName = @"Mock UI";
    COMComponentEntity *cItem = [COMComponentEntity new];
    cItem.componentName = @"Slider";
    COMComponentEntity *cItem2 = [COMComponentEntity new];
    cItem2.componentName = @"Button";
    item.components = @[ cItem, cItem2 ];
    self.sources = @[ item ];
}

- (void)onSourceChanged:(NSMenuItem *)sender {
    if (sender.tag < self.sources.count) {
        self.currentSource = self.sources[sender.tag];
        [self.collectionView reloadData];
    }
}

@end
