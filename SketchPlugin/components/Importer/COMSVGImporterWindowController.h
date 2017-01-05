//
//  SSVGWindowController.h
//  Sketch-SVGImporter
//
//  Created by 崔明辉 on 2017/1/5.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface COMSVGImporterWindowController : NSWindowController

@property (assign) NSModalSession modalSession;
@property (weak) IBOutlet NSTextField *filePathTextField;
@property (weak) IBOutlet WebView *webView;

@end
