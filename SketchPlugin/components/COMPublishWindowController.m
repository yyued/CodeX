//
//  COMPublishWindowController.m
//  components
//
//  Created by 崔明辉 on 2016/12/8.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMPublishWindowController.h"

@interface COMPublishWindowController ()

@property(nonatomic, strong) MSLayer *currentLayer;

@property(weak) IBOutlet NSTextField *targetTextField;
@property(weak) IBOutlet NSButton *outtypeViewController;
@property(weak) IBOutlet NSButton *outtypeView;
@property(weak) IBOutlet NSTextField *classNameTextField;
@property(weak) IBOutlet NSTextField *classSuffix;
@property(weak) IBOutlet NSTextField *pathTextField;

@end

@implementation COMPublishWindowController

+ (instancetype) new {
    COMPublishWindowController *obj = [[COMPublishWindowController alloc] init];
    NSString *nibPath = [[[NSBundle bundleForClass:[self class]] bundlePath]
        stringByAppendingString:@"/Contents/Resources/COMPublishWindowController.nib"];
    [[[NSNib alloc] initWithNibData:[NSData dataWithContentsOfFile:nibPath] bundle:nil] instantiateWithOwner:obj
                                                                                             topLevelObjects:nil];
    return obj;
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void)cancelOperation:(id)sender {
    [[NSApplication sharedApplication] endModalSession:self.modalSession];
    [self close];
}

- (IBAction)onFileChooseButtonClicked:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setAllowsMultipleSelection:NO];
    NSInteger result = [openPanel runModal];
    if (result == NSFileHandlingPanelOKButton) {
        [self.pathTextField setStringValue:[openPanel.URL path]];
    }
}

- (IBAction)onCancel:(id)sender {
    [[NSApplication sharedApplication] endModalSession:self.modalSession];
    [self close];
}

- (IBAction)onPublish:(id)sender {
    if (self.currentLayer == nil) {
        return;
    }
    MSLayer *newLayer = [self.currentLayer duplicate];
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    [self fetchProps:newLayer props:props];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        MSExportRequest *request = [MSExportRequest_Class exportRequestsFromExportableLayer:newLayer].firstObject;
        [[MSDocument_Class currentDocument] saveArtboardOrSlice:request toFile:@"/tmp/com.yy.ued.sketch.components.tmp.svg"];
        [[NSJSONSerialization dataWithJSONObject:[props copy] options:kNilOptions error:NULL]
         writeToFile:@"/tmp/com.yy.ued.sketch.components.tmp.json"
         atomically:YES];
        [newLayer removeFromParent];
        [[NSApplication sharedApplication] endModalSession:self.modalSession];
        [self close];
    });
}

- (void)fetchProps:(MSLayer *)layer props:(NSMutableDictionary *)props {
    static MSPluginCommand *command;
    static JSContext *context;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        command = [MSPluginCommand_Class new];
        context = [JSContext new];
        [context evaluateScript:@"function a(b){eval('var e = '+b);return e}"];
    });
    NSString *pString =
        [command valueForKey:@"props" onLayer:layer forPluginIdentifier:@"com.yy.ued.sketch.components"];
    if ([pString isKindOfClass:[NSString class]]) {
        NSString *uuid = [[NSUUID UUID] UUIDString];
        [layer setName:uuid];
        context[@"pString"] = ^(){
            return pString;
        };
        JSValue *value = [context evaluateScript:@"a(pString())"];
        NSDictionary *dict = [value toDictionary];
        if (dict != nil) {
            NSString *cDict =
            [command valueForKey:@"constraints" onLayer:layer forPluginIdentifier:@"com.matt-curtis.sketch.constraints"];
            if ([cDict isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *mDict = [dict mutableCopy];
                mDict[@"constraints"] = cDict;
                dict = [mDict copy];
            }
            props[uuid] = dict;
        }
    }
    if ([layer isKindOfClass:MSLayerGroup_Class]) {
        for (MSLayer *sublayer in [(MSLayerGroup *)layer layers]) {
            [self fetchProps:sublayer props:props];
        }
    }
}

- (IBAction)onOuttypeViewController:(id)sender {
    [self.outtypeViewController setState:1];
    [self.outtypeView setState:0];
    [self.classSuffix setStringValue:@"ViewController(Activity)"];
}

- (IBAction)onOuttypeView:(id)sender {
    [self.outtypeViewController setState:0];
    [self.outtypeView setState:1];
    [self.classSuffix setStringValue:@"View"];
}

#pragma mark - Setter

- (void)setLayer:(MSLayer *)layer {
    self.currentLayer = layer;
    [self.targetTextField setStringValue:[NSString stringWithFormat:@"Target -> %@", layer.name]];
    [self.classNameTextField setStringValue:layer.name];
}

@end
