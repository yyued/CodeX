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
        [[NSUserDefaults standardUserDefaults] setValue:[openPanel.URL path] forKey:@"com.yy.ued.sketch.components.libPath"];
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

@end
