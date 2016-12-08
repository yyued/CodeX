//
//  COMPropsWindowController.h
//  components
//
//  Created by 崔明辉 on 2016/12/8.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MCSketchPluginFramework/MCSketchPluginFramework.h>

@interface COMPropsWindowController : NSWindowController

@property (assign) NSModalSession modalSession;
@property (unsafe_unretained) IBOutlet NSTextView *textView;

- (void)setLayer:(MSLayer *)layer;

@end
