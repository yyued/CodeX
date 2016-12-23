//
//  COMComponentWindowController.m
//  components
//
//  Created by 崔明辉 on 2016/12/7.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMComponentWindowController.h"
#import "COMComponentCollectionViewItem.h"
#import "COMComponentSourceEntity.h"

@interface COMComponentWindowController ()<NSCollectionViewDataSource, NSCollectionViewDelegate, NSOutlineViewDelegate, NSOutlineViewDataSource>

@property (nonatomic, copy) NSArray<COMComponentSourceEntity *> *sources;
@property (nonatomic, strong) NSString *currentFilter;
@property (nonatomic, strong) COMComponentSourceEntity *currentSource;

@end

@implementation COMComponentWindowController

+ (instancetype) new {
    COMComponentWindowController *obj = [[COMComponentWindowController alloc] init];
    NSString *nibPath = [[[NSBundle bundleForClass:[self class]] bundlePath]
        stringByAppendingString:@"/Contents/Resources/COMComponentWindowController.nib"];
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
        item.titleView.string = [componentItem.componentName
                                 stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/", self.currentFilter]
                                 withString:@""];
        item.iconImageView.image = componentItem.iconImage;
    }
    return item;
}

- (NSArray *)filteredComponents {
    if (self.currentFilter == nil) {
        return self.currentSource.components;
    }
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(COMComponentEntity * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject.componentName hasPrefix:[NSString stringWithFormat:@"%@/", self.currentFilter]] ||
        [evaluatedObject.componentName isEqualToString:self.currentFilter];
    }];
    return [self.currentSource.components filteredArrayUsingPredicate:predicate];
}

#pragma mark - NSOutlineView DataSource & Delegate

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return self.currentSource.categories.count;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (index < self.currentSource.categories.count) {
        return self.currentSource.categories[index];
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
    if ([self.outlineView selectedRow] < self.currentSource.categories.count) {
        self.currentFilter = self.currentSource.categories[[self.outlineView selectedRow]];
        [[self.collectionView visibleItems] enumerateObjectsUsingBlock:^(NSCollectionViewItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [(COMComponentCollectionViewItem *)obj selectedLayer].hidden = YES;
        }];
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
    [self.sources enumerateObjectsUsingBlock:^(COMComponentSourceEntity *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
      NSMenuItem *menuItem =
          [[NSMenuItem alloc] initWithTitle:obj.sourceName action:@selector(onSourceChanged:) keyEquivalent:@""];
      menuItem.tag = idx;
      [self.sourceMenu addItem:menuItem];
    }];
    self.currentSource = self.sources.firstObject;
    self.currentFilter = nil;
    [self.collectionView reloadData];
    [self.outlineView reloadData];
}

- (void)fetchSketchSources {
    NSArray<MSPage *> *pages = [[MSDocument_Class currentDocument] pages];
    NSMutableArray<COMComponentSourceEntity *> *items = [NSMutableArray array];
    [pages enumerateObjectsUsingBlock:^(MSPage *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
      if ([obj.name hasPrefix:@"TPL - "]) {
          COMComponentSourceEntity *item = [COMComponentSourceEntity new];
          item.sourceName = [obj.name stringByReplacingOccurrencesOfString:@"TPL - " withString:@""];
          NSMutableArray<COMComponentEntity *> *components = [NSMutableArray array];
          for (MSArtboardGroup *artboard in [obj artboards]) {
              for (MSLayerGroup *layer in [artboard layers]) {
                  if ([layer isKindOfClass:MSLayerGroup_Class] &&
                      [[MSPluginCommand_Class new] valueForKey:@"class"
                                                       onLayer:layer
                                           forPluginIdentifier:@"com.yy.ued.sketch.components"] != nil) {
                      COMComponentEntity *componentItem = [COMComponentEntity new];
                      componentItem.componentName = [layer name];
                      componentItem.componentLayer = layer;
                      componentItem.iconImage = [componentItem snapImage];
                      [components insertObject:componentItem atIndex:0];
                  }
              }
          }
          item.components = components;
          [items addObject:item];
      }
    }];
    self.sources = items;
}

- (void)fetchMockSources {
    COMComponentSourceEntity *item = [COMComponentSourceEntity new];
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
        self.currentFilter = nil;
        [self.collectionView reloadData];
        [self.outlineView reloadData];
    }
}

@end
