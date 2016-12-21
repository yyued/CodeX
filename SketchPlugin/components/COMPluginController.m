//
//  COMPluginController.m
//  components
//
//  Created by 崔明辉 on 2016/12/7.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMPluginController.h"
#import "COMModalWindowController.h"
#import "COMPublishWindowController.h"
#import "COMSidebarViewController.h"

static COMModalWindowController *modalWindowController;
static COMPublishWindowController *publishWindowController;

@interface COMPluginController ()

@end

@implementation COMPluginController

+ (void)load {
    [[NSFileManager defaultManager] createDirectoryAtPath:@"/tmp/com.yy.ued.sketch.components"
                              withIntermediateDirectories:NO
                                               attributes:nil
                                                    error:NULL];
}

+ (instancetype)pluginController:(MSPluginBundle *)plugin pluginCommand:(MSPluginCommand *)pluginCommand {
    return [COMPluginController new];
}

- (void)showLibraryChooser {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setAllowsMultipleSelection:NO];
    NSInteger result = [openPanel runModal];
    if (result == NSFileHandlingPanelOKButton) {
        [[NSUserDefaults standardUserDefaults] setValue:[openPanel.URL path]
                                                 forKey:@"com.yy.ued.sketch.components.libPath"];
    }
}

- (void)showSidebar {
    [COMSidebarViewController toggleSidebar];
}

- (void)showDialog:(BOOL)replacing {
    if (modalWindowController == nil) {
        modalWindowController = [COMModalWindowController new];
    }
    modalWindowController.replacing = replacing;
    [modalWindowController requestSources];
    modalWindowController.modalSession =
        [[NSApplication sharedApplication] beginModalSessionForWindow:modalWindowController.window];
}

- (void)showPublisher {
    if (publishWindowController == nil) {
        publishWindowController = [COMPublishWindowController new];
    }
    MSLayer *layer = [[[MSDocument_Class currentDocument] selectedLayers] firstObject];
    if (layer != nil && [layer isKindOfClass:MSLayer_Class]) {
        [publishWindowController setLayer:layer];
    } else {
        [publishWindowController setLayer:[[[[MSDocument_Class currentDocument] currentPage] artboards] firstObject]];
    }
    publishWindowController.modalSession =
        [[NSApplication sharedApplication] beginModalSessionForWindow:publishWindowController.window];
}

- (void)addBounds {
    [self addBounds:Sketch_GetSelectedLayers(Sketch_GetCurrentDocument())];
}

- (void)addBounds:(NSArray *)layers {
    [layers enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
      if ([obj isKindOfClass:MSLayerGroup_Class] && ![obj isKindOfClass:MSShapeGroup_Class]) {
          MSLayerGroup *current = obj;
          for (MSLayer *sublayer in [current layers]) {
              [self addBounds:@[sublayer]];
          }
          if ([[MSPluginCommand_Class new] valueForKey:@"class"
                                               onLayer:current
                                   forPluginIdentifier:@"com.yy.ued.sketch.components"] == nil) {
              return;
          }
          BOOL foundBounds = NO;
          for (MSLayer *sublayer in [current layers]) {
              if ([sublayer.name isEqualToString:@"Bounds"]) {
                  foundBounds = YES;
              }
          }
          if (!foundBounds) {
              MSShapeGroup *shapeGroup = [[MSShapeGroup_Class alloc] init];
              shapeGroup.name = @"Bounds";
              shapeGroup.frame = [[MSRect_Class alloc] init];
              shapeGroup.frame.width = current.frame.width;
              shapeGroup.frame.height = current.frame.height;
              MSLayer *rectangeShape = [[NSClassFromString(@"MSRectangleShape") alloc] init];
              rectangeShape.frame = shapeGroup.frame;
              [shapeGroup addLayers:@[ rectangeShape ]];
              [[MSPluginCommand_Class new] setValue:@{
                  @"centerHorizontally" : @(1),
                  @"centerVertically" : @(1),
                  @"centerRelativeTo" : @(1),
                  @"useFixedWidth": @(1),
                  @"useFixedHeight": @(1),
                  @"fixedWidth" : @"100%",
                  @"fixedHeight" : @"100%",
                  @"sizeRelativeTo" : @(1),
              }
                                             forKey:@"constraints"
                                            onLayer:shapeGroup
                                forPluginIdentifier:@"com.matt-curtis.sketch.constraints"];
              [[MSPluginCommand_Class new] setValue:@{
                  @"centerHorizontally" : @(1),
                  @"centerVertically" : @(1),
                  @"centerRelativeTo" : @(1),
                  @"useFixedWidth": @(1),
                  @"useFixedHeight": @(1),
                  @"fixedWidth" : @"100%",
                  @"fixedHeight" : @"100%",
                  @"sizeRelativeTo" : @(1),
              }
                                             forKey:@"constraints"
                                            onLayer:shapeGroup
                                forPluginIdentifier:@"com.yy.ued.sketch.components"];
              [current insertLayers:@[ shapeGroup ] atIndex:0];
          }
      }
    }];
}

@end
