//
//  CollectionViewItem.h
//  NSCollectionCodeView
//
//  Created by zhaojw on 15/8/28.
//  Copyright (c) 2015年 zhaojw. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "COMModalWindowController.h"

@interface COMComponentCollectionViewItem : NSCollectionViewItem

@property (nonatomic, weak) COMModalWindowController *modalWindowController;
@property (nonatomic, strong) CALayer *selectedLayer;
@property (nonatomic, strong) NSImageView *iconImageView;
@property (nonatomic, strong) NSTextView *titleView;

@end
