//
//  COMPublishWindowController.m
//  components
//
//  Created by 崔明辉 on 2016/12/8.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMPublishWindowController.h"
#import "COMGenerator.h"

@interface COMPublishWindowController ()

@property(nonatomic, strong) MSLayer *currentLayer;

@property(weak) IBOutlet NSTextField *targetTextField;
@property(weak) IBOutlet NSButton *outtypeViewController;
@property(weak) IBOutlet NSButton *outtypeView;
@property(weak) IBOutlet NSTextField *classNameTextField;
@property(weak) IBOutlet NSTextField *pathTextField;
@property (weak) IBOutlet NSTextField *libPathTextField;

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

- (void)awakeFromNib {
    [super awakeFromNib];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"com.yy.ued.sketch.components.outtypeView"] isKindOfClass:[NSNumber class]]) {
            [self.outtypeView setState:[[[NSUserDefaults standardUserDefaults] valueForKey:@"com.yy.ued.sketch.components.outtypeView"] integerValue]];
        }
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"com.yy.ued.sketch.components.outtypeViewController"] isKindOfClass:[NSNumber class]]) {
            [self.outtypeViewController setState:[[[NSUserDefaults standardUserDefaults] valueForKey:@"com.yy.ued.sketch.components.outtypeViewController"] integerValue]];
        }s
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"com.yy.ued.sketch.components.className"] isKindOfClass:[NSString class]]) {
            [self.classNameTextField setStringValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"com.yy.ued.sketch.components.className"]];
        }
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"com.yy.ued.sketch.components.outPath"] isKindOfClass:[NSString class]]) {
            [self.pathTextField setStringValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"com.yy.ued.sketch.components.outPath"]];
        }
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"com.yy.ued.sketch.components.libPath"] isKindOfClass:[NSString class]]) {
            [self.libPathTextField setStringValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"com.yy.ued.sketch.components.libPath"]];
        }
    });
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
        [[NSUserDefaults standardUserDefaults] setValue:[openPanel.URL path] forKey:@"com.yy.ued.sketch.components.outPath"];
    }
}

- (IBAction)onLibChooseButtonClicked:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setAllowsMultipleSelection:NO];
    NSInteger result = [openPanel runModal];
    if (result == NSFileHandlingPanelOKButton) {
        [self.libPathTextField setStringValue:[openPanel.URL path]];
        [[NSUserDefaults standardUserDefaults] setValue:[openPanel.URL path] forKey:@"com.yy.ued.sketch.components.libPath"];
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
    if ([self.currentLayer isKindOfClass:MSArtboardGroup_Class]) {
        [newLayer.frame setOrigin:CGPointMake(1000000, 1000000)];
    }
    else {
        [self.currentLayer performSelector:@selector(setIsVisible:) withObject:@(NO)];
    }
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    [self fetchProps:newLayer props:props];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        MSExportRequest *request = [MSExportRequest_Class exportRequestsFromExportableLayer:newLayer].firstObject;
        [[MSDocument_Class currentDocument] saveArtboardOrSlice:request toFile:@"/tmp/com.yy.ued.sketch.components/tmp.svg"];
        [[NSJSONSerialization dataWithJSONObject:[props copy] options:kNilOptions error:NULL]
         writeToFile:@"/tmp/com.yy.ued.sketch.components/tmp.json"
         atomically:YES];
        COMGenerator *generator = [COMGenerator new];
        generator.libraryPath = self.libPathTextField.stringValue;
        generator.className = self.classNameTextField.stringValue;
        COMGenLayer *layer = [generator parse];
        [[generator oc_code:layer genType:self.outtypeView.state == 0 ? COMGenTypeViewController : COMGenTypeView]
         enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, NSString *  _Nonnull obj, BOOL * _Nonnull stop) {
            [obj writeToFile:[NSString stringWithFormat:@"%@/%@", self.pathTextField.stringValue, key]
                  atomically:YES
                    encoding:NSUTF8StringEncoding
                       error:NULL];
        }];
        [newLayer removeFromParent];
        [[NSApplication sharedApplication] endModalSession:self.modalSession];
        [self close];
        if (![self.currentLayer isKindOfClass:MSArtboardGroup_Class]) {
            [self.currentLayer performSelector:@selector(setIsVisible:) withObject:@(YES)];
        }
    });
    [[NSUserDefaults standardUserDefaults] setValue:self.classNameTextField.stringValue forKey:@"com.yy.ued.sketch.components.className"];
    [[NSUserDefaults standardUserDefaults] setValue:@(self.outtypeView.state) forKey:@"com.yy.ued.sketch.components.outtypeView"];
    [[NSUserDefaults standardUserDefaults] setValue:@(self.outtypeViewController.state) forKey:@"com.yy.ued.sketch.components.outtypeViewController"];
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
}

- (IBAction)onOuttypeView:(id)sender {
    [self.outtypeViewController setState:0];
    [self.outtypeView setState:1];
}

#pragma mark - Setter

- (void)setLayer:(MSLayer *)layer {
    self.currentLayer = layer;
    [self.targetTextField setStringValue:[NSString stringWithFormat:@"Target -> %@", layer.name]];
}

@end
