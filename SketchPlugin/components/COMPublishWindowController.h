//
//  COMPublishWindowController.h
//  components
//
//  Created by 崔明辉 on 2016/12/8.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MCSketchPluginFramework/MCSketchPluginFramework.h>

@interface COMPublishWindowController : NSWindowController

@property (assign) NSModalSession modalSession;

- (void)setLayer:(MSLayer *)layer;

@end
