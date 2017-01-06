//
//  SSVGWindowController.m
//  Sketch-SVGImporter
//
//  Created by 崔明辉 on 2017/1/5.
//  Copyright © 2017年 UED Center. All rights reserved.
//

#import "COMSVGImporterWindowController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "COMSVGImporterEntities.h"

@interface COMSVGImporterWindowController ()<NSTextFieldDelegate, WebFrameLoadDelegate>

@property (nonatomic, strong) COMSVGCanvasEntity *currentCanvas;

@end

@implementation COMSVGImporterWindowController

+ (instancetype) new {
    COMSVGImporterWindowController *obj = [[COMSVGImporterWindowController alloc] init];
    NSString *nibPath = [[[NSBundle bundleForClass:[self class]] bundlePath]
        stringByAppendingString:@"/Contents/Resources/COMSVGImporterWindowController.nib"];
    [[[NSNib alloc] initWithNibData:[NSData dataWithContentsOfFile:nibPath] bundle:nil] instantiateWithOwner:obj
                                                                                             topLevelObjects:nil];
    return obj;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.filePathTextField.delegate = self;
    self.webView.frameLoadDelegate = self;
    NSClickGestureRecognizer *clickGestureRecognizer =
        [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(onChooseButtonClicked:)];
    clickGestureRecognizer.numberOfClicksRequired = 2;
    [self.filePathTextField addGestureRecognizer:clickGestureRecognizer];
}

- (BOOL)windowShouldClose:(id)sender {
    [[NSApplication sharedApplication] endModalSession:self.modalSession];
    [self.window close];
    return YES;
}

- (void)controlTextDidEndEditing:(NSNotification *)obj {
    [self loadPage];
}

- (IBAction)onChooseButtonClicked:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.allowsMultipleSelection = NO;
    openPanel.allowedFileTypes = @[ @"svg" ];
    NSInteger result = [openPanel runModal];
    if (result == NSFileHandlingPanelOKButton) {
        [self.filePathTextField setStringValue:[openPanel.URL absoluteString]];
        [self loadPage];
    }
}

- (IBAction)onImportButtonClicked:(id)sender {
    
    NSString *currentSelectedWidth = self.widthButton.selectedItem.title;
    CGFloat toWidth = [[currentSelectedWidth stringByReplacingOccurrencesOfString:@"W = " withString:@""] floatValue];
    [self.currentCanvas exportToSketch:toWidth];
    [[NSApplication sharedApplication] endModalSession:self.modalSession];
    [self.window close];
}


- (void)loadPage {
    self.importButton.enabled = NO;
    [self.webView.mainFrame
        loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.filePathTextField.stringValue]]];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    if (frame == self.webView.mainFrame) {
        [self startParsing];
    }
}

- (void)startParsing {
    static WebView *parsingWebView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        parsingWebView = [WebView new];
    });
    JSContext *context = parsingWebView.mainFrame.javaScriptContext;
    {
        NSString *script = [NSString stringWithContentsOfFile:
                            [[[NSBundle bundleForClass:[self class]] bundlePath]
                             stringByAppendingString:@"/Contents/Resources/fabric.require.js"]
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
        [context evaluateScript:script];
    }
    {
        NSString *script = [NSString
                            stringWithContentsOfFile:[[[NSBundle bundleForClass:[self class]] bundlePath]
                                                      stringByAppendingString:@"/Contents/Resources/fabric.min.js"]
                            encoding:NSUTF8StringEncoding
                            error:nil];
        [context evaluateScript:script];
    }
    {
        NSString *script = [NSString
                            stringWithContentsOfFile:[[[NSBundle bundleForClass:[self class]] bundlePath]
                                                      stringByAppendingString:@"/Contents/Resources/fabric.helper.js"]
                            encoding:NSUTF8StringEncoding
                            error:nil];
        [context evaluateScript:script];
    }
    NSString *xml = [[NSString alloc] initWithData:self.webView.mainFrame.dataSource.data encoding:NSUTF8StringEncoding];
    if (xml == nil || xml.length == 0) {
        return;
    }
    [context[@"loadSVG"] callWithArguments:@[xml, ^(NSArray *elements, NSDictionary *options){
        COMSVGCanvasEntity *canvas = [COMSVGCanvasEntity new];
        [canvas parseWithElements:elements options:options];
        self.currentCanvas = canvas;
        self.importButton.enabled = YES;
    }]];
}

@end
