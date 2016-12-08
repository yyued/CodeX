//
//  COMModalWindowController.h
//  components
//
//  Created by 崔明辉 on 2016/12/7.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface COMModalWindowController : NSWindowController

@property (assign) NSModalSession modalSession;
@property (nonatomic, assign) BOOL replacing;
@property (weak) IBOutlet NSMenu *sourceMenu;
@property (weak) IBOutlet NSCollectionView *collectionView;
@property (weak) IBOutlet NSOutlineView *outlineView;

- (void)requestSources;

@end
