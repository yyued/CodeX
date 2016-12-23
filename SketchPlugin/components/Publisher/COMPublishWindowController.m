//
//  COMPublishWindowController.m
//  components
//
//  Created by 崔明辉 on 2016/12/8.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMPublishWindowController.h"
#import "COMGenerator.h"
#import "COMAssetsWritter.h"

@interface COMPublishWindowController ()

@property(nonatomic, strong) MSLayer *currentLayer;

@property(weak) IBOutlet NSTextField *targetTextField;
@property(weak) IBOutlet NSButton *outtypeViewController;
@property(weak) IBOutlet NSButton *outtypeView;
@property(weak) IBOutlet NSTextField *classNameTextField;
@property(weak) IBOutlet NSTextField *pathTextField;
@property (weak) IBOutlet NSTextField *assetsTextField;
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
        }
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"com.yy.ued.sketch.components.className"] isKindOfClass:[NSString class]]) {
            [self.classNameTextField setStringValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"com.yy.ued.sketch.components.className"]];
        }
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"com.yy.ued.sketch.components.outPath"] isKindOfClass:[NSString class]]) {
            [self.pathTextField setStringValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"com.yy.ued.sketch.components.outPath"]];
        }
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"com.yy.ued.sketch.components.libPath"] isKindOfClass:[NSString class]]) {
            [self.libPathTextField setStringValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"com.yy.ued.sketch.components.libPath"]];
        }
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"com.yy.ued.sketch.components.assetsPath"] isKindOfClass:[NSString class]]) {
            [self.assetsTextField setStringValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"com.yy.ued.sketch.components.assetsPath"]];
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

- (IBAction)onAssetsChooseButtonClicked:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setAllowsMultipleSelection:NO];
    NSInteger result = [openPanel runModal];
    if (result == NSFileHandlingPanelOKButton) {
        [self.assetsTextField setStringValue:[openPanel.URL path]];
        [[NSUserDefaults standardUserDefaults] setValue:[openPanel.URL path] forKey:@"com.yy.ued.sketch.components.assetsPath"];
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
        [newLayer.frame setWidth:100000];
        [newLayer.frame setHeight:100000];
    }
    else {
        [self.currentLayer performSelector:@selector(setIsVisible:) withObject:@(NO)];
    }
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    NSMutableDictionary *layers = [NSMutableDictionary dictionary];
    [self resetConditionView:newLayer];
    [self fetchProps:newLayer props:props layers:layers];
    [self saveShapesAsAssets:layers props:props];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        MSExportRequest *request = [MSExportRequest_Class exportRequestsFromExportableLayer:newLayer].firstObject;
        [[MSDocument_Class currentDocument] saveArtboardOrSlice:request toFile:@"/tmp/com.yy.ued.sketch.components/tmp.svg"];
        [[NSJSONSerialization dataWithJSONObject:[props copy] options:kNilOptions error:NULL]
         writeToFile:@"/tmp/com.yy.ued.sketch.components/tmp.json"
         atomically:YES];
        COMGenerator *generator = [COMGenerator new];
        generator.assetsPath = self.assetsTextField.stringValue;
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

- (void)fetchProps:(MSLayer *)layer props:(NSMutableDictionary *)props layers:(NSMutableDictionary *)layers {
    static MSPluginCommand *command;
    static JSContext *context;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        command = [MSPluginCommand_Class new];
        context = [JSContext new];
        [context evaluateScript:@"function a(b){eval('var e = '+b);return e}"];
    });
    NSString *className = [command valueForKey:@"class" onLayer:layer forPluginIdentifier:@"com.yy.ued.sketch.components"];
    NSDictionary *layerProps = [command valueForKey:@"props" onLayer:layer forPluginIdentifier:@"com.yy.ued.sketch.components"];
    if (className != nil && className.length) {
        if (![layerProps isKindOfClass:[NSDictionary class]]) {
            layerProps = @{};
        }
        NSString *uuid = [[NSUUID UUID] UUIDString];
        if ([className isEqualToString:@"UIImageView"]) {
            NSMutableDictionary *mDict = [layerProps mutableCopy];
            mDict[@"sourceName"] = [COMAssetsWritter stripFilename:layer.name];
            if ([layer isKindOfClass:MSShapeGroup_Class]) {
                mDict[@"sourceType"] = @"Shape";
            }
            layerProps = [mDict copy];
        }
        [layer setName:uuid];
        {
            NSMutableDictionary *mDict = [layerProps mutableCopy];
            mDict[@"class"] = className;
            layerProps = [mDict copy];
        }
        {
            NSMutableDictionary *mDict = [layerProps mutableCopy];
            [[mDict copy] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if (mDict[[NSString stringWithFormat:@"_%@", key]] != nil &&
                    [mDict[[NSString stringWithFormat:@"_%@", key]] isEqualToString:@"Enum"] &&
                    [obj isKindOfClass:[NSArray class]] &&
                    [obj firstObject] != nil) {
                    [mDict setObject:[obj firstObject] forKey:key];
                }
            }];
            layerProps = [mDict copy];
        }
        {
            NSString *cDict =
            [command valueForKey:@"constraints" onLayer:layer forPluginIdentifier:@"com.matt-curtis.sketch.constraints"];
            if ([cDict isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *mDict = [layerProps mutableCopy];
                mDict[@"constraints"] = cDict;
                layerProps = [mDict copy];
            }
        }
        if ([layer isKindOfClass:MSTextLayer_Class]) {
            NSNumber *alignment = [(MSTextLayer *)layer valueForKey:@"textAlignment"];
            if (alignment != nil) {
                NSMutableDictionary *mDict = [layerProps mutableCopy];
                mDict[@"alignment"] = alignment;
                layerProps = [mDict copy];
            }
        }
        props[uuid] = layerProps;
        layers[uuid] = layer;
    }
    if ([layer isKindOfClass:MSLayerGroup_Class]) {
        for (MSLayer *sublayer in [(MSLayerGroup *)layer layers]) {
            [self fetchProps:sublayer props:props layers:layers];
        }
    }
}

- (void)resetConditionView:(MSLayer *)layer {
    static MSPluginCommand *command;
    static JSContext *context;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        command = [MSPluginCommand_Class new];
        context = [JSContext new];
        [context evaluateScript:@"function a(b){eval('var e = '+b);return e}"];
    });
    NSString *className = [command valueForKey:@"class" onLayer:layer forPluginIdentifier:@"com.yy.ued.sketch.components"];
    NSDictionary *layerProps = [command valueForKey:@"props" onLayer:layer forPluginIdentifier:@"com.yy.ued.sketch.components"];
    NSDictionary *constraints = [command valueForKey:@"constraints" onLayer:layer forPluginIdentifier:@"com.matt-curtis.sketch.constraints"];
    if ([className isEqualToString:@"UIConditionView"] || [className isEqualToString:@"COXButton"]) {
        MSLayerGroup *newGroup = [MSLayerGroup_Class new];
        newGroup.frame = layer.frame;
        [command setValue:className
                   forKey:@"class"
                  onLayer:newGroup
      forPluginIdentifier:@"com.yy.ued.sketch.components"];
        if (layerProps != nil) {
            [command setValue:layerProps
                       forKey:@"props"
                      onLayer:newGroup
          forPluginIdentifier:@"com.yy.ued.sketch.components"];
        }
        if (constraints != nil) {
            [command setValue:constraints
                       forKey:@"constraints"
                      onLayer:newGroup
          forPluginIdentifier:@"com.yy.ued.sketch.components"];
            [command setValue:constraints
                       forKey:@"constraints"
                      onLayer:newGroup
          forPluginIdentifier:@"com.matt-curtis.sketch.constraints"];
        }
        [[layer parentGroup] insertLayers:@[newGroup] afterLayer:layer];
        [layer removeFromParent];
        [layerProps enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([key hasPrefix:@"where"]) {
                MSLayer *targetLayer = [self findLayerWithName:obj];
                if (targetLayer != nil) {
                    targetLayer = [targetLayer duplicate];
                    [targetLayer removeFromParent];
                    MSLayerGroup *subGroup = [MSLayerGroup_Class new];
                    subGroup.name = key;
                    subGroup.frame.x = 0;
                    subGroup.frame.y = 0;
                    subGroup.frame.width = newGroup.frame.width;
                    subGroup.frame.height = newGroup.frame.height;
                    targetLayer.frame.x = 0;
                    targetLayer.frame.y = 0;
                    targetLayer.frame.width = subGroup.frame.width;
                    targetLayer.frame.height = subGroup.frame.height;
                    NSNumber *tag = [[NSNumberFormatter new]
                                     numberFromString:[[key componentsSeparatedByString:@"="] lastObject]];
                    if (tag == nil) {
                        tag = @(0);
                    }
                    [command setValue:@"UIView"
                               forKey:@"class"
                              onLayer:targetLayer
                  forPluginIdentifier:@"com.yy.ued.sketch.components"];
                    [command setValue:@{
                                        @"tag": tag
                                        }
                               forKey:@"props"
                              onLayer:targetLayer
                  forPluginIdentifier:@"com.yy.ued.sketch.components"];
                    [command setValue:@{
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
                              onLayer:targetLayer
                  forPluginIdentifier:@"com.yy.ued.sketch.components"];
                    [command setValue:@{
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
                              onLayer:targetLayer
                  forPluginIdentifier:@"com.matt-curtis.sketch.constraints"];
                    [subGroup addLayers:@[targetLayer]];
                    [newGroup addLayers:@[subGroup]];
                }
            }
        }];
    }
    if ([layer isKindOfClass:MSLayerGroup_Class]) {
        for (MSLayer *sublayer in [(MSLayerGroup *)layer layers]) {
            [self resetConditionView:sublayer];
        }
    }
}

- (void)saveShapesAsAssets:(NSDictionary *)layers props:(NSDictionary *)props {
    NSString *assetsPath = self.assetsTextField.stringValue;
    [props enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![obj[@"class"] isKindOfClass:[NSString class]] ||
            ![obj[@"sourceType"] isKindOfClass:[NSString class]] ||
            ![obj[@"sourceName"] isKindOfClass:[NSString class]]) {
            return;
        }
        if ([obj[@"class"] isEqualToString:@"UIImageView"] && [obj[@"sourceType"] isEqualToString:@"Shape"]) {
            MSLayer *layer = layers[key];
            if (layer == nil) {
                return;
            }
            MSExportRequest *request = [(id)[MSExportRequest_Class exportRequestsFromExportableLayer:layer] firstObject];
            [request setValue:@(3.0) forKey:@"scale"];
            [[MSDocument_Class currentDocument] saveArtboardOrSlice:request toFile:@"/tmp/com.yy.ued.sketch.components/tmp.png"];
            NSImage *image = [[NSImage alloc] initWithContentsOfFile:@"/tmp/com.yy.ued.sketch.components/tmp.png"];
            [COMAssetsWritter writeIOSImage:image
                                   baseSize:CGSizeMake(image.size.width / 6.0, image.size.height / 6.0)
                               toAssetsPath:assetsPath
                                   fileName:obj[@"sourceName"]];
        }
    }];
}

- (IBAction)onOuttypeViewController:(id)sender {
    [self.outtypeViewController setState:1];
    [self.outtypeView setState:0];
}

- (IBAction)onOuttypeView:(id)sender {
    [self.outtypeViewController setState:0];
    [self.outtypeView setState:1];
}

#pragma mark - Helper

- (MSLayer *)findLayerWithName:(NSString *)name {
    for (MSPage *page in [Sketch_GetCurrentDocument() pages]) {
        if (![page.name hasPrefix:@"TPL"]) {
            continue;
        }
        for (MSArtboardGroup *artboard in page.artboards) {
            for (MSLayer *layer in artboard.layers) {
                if ([layer.name isEqualToString:name]) {
                    return layer;
                }
            }
        }
    }
    return nil;
}

#pragma mark - Setter

- (void)setLayer:(MSLayer *)layer {
    self.currentLayer = layer;
    [self.targetTextField setStringValue:[NSString stringWithFormat:@"Target -> %@", layer.name]];
}

@end
