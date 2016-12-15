//
//  COMPluginController.h
//  components
//
//  Created by 崔明辉 on 2016/12/7.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MCSketchPluginFramework/MCSketchPluginFramework.h>

@interface COMPluginController : MCSPluginController

- (void)showLibraryChooser;

- (void)showSidebar;

- (void)showDialog:(BOOL)replacing;

- (void)showPublisher;

@end
