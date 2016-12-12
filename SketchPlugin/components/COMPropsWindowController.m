//
//  COMPropsWindowController.m
//  components
//
//  Created by 崔明辉 on 2016/12/8.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMPropsWindowController.h"

@interface COMPropsWindowController ()

@property(nonatomic, strong) MSLayer *currentLayer;

@end

@implementation COMPropsWindowController

+ (instancetype) new {
    COMPropsWindowController *obj = [[COMPropsWindowController alloc] init];
    NSString *nibPath = [[[NSBundle bundleForClass:[self class]] bundlePath]
        stringByAppendingString:@"/Contents/Resources/COMPropsWindowController.nib"];
    [[[NSNib alloc] initWithNibData:[NSData dataWithContentsOfFile:nibPath] bundle:nil] instantiateWithOwner:obj
                                                                                             topLevelObjects:nil];
    return obj;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.textView.automaticQuoteSubstitutionEnabled = NO;
    self.textView.enabledTextCheckingTypes = 0;
}

- (void)setLayer:(MSLayer *)layer {
    self.currentLayer = layer;
    NSString *props = [[MSPluginCommand_Class new] valueForKey:@"props"
                                                       onLayer:layer
                                           forPluginIdentifier:@"com.yy.ued.sketch.components"];
    if (props == nil || props.length == 0 || ![props isKindOfClass:[NSString class]]) {
        if ([layer isKindOfClass:MSTextLayer_Class]) {
            [self.textView setString:@"{\n      class: \"UILabel\",\n      outlet: \"\",\n      numberOfLines: 1,\n      maxWidth: 0,\n}"];
        }
        else {
            [self.textView setString:@"{\n      class: \"UIView\",\n      outlet: \"\",\n}"];
        }
    } else {
        [self.textView setString:props];
    }
}

- (void)cancelOperation:(id)sender {
    [self onDiscard:nil];
}

- (IBAction)onSave:(id)sender {
    [[NSApplication sharedApplication] endModalSession:self.modalSession];
    [self close];
    if (self.currentLayer != nil) {
        [[MSPluginCommand_Class new] setValue:self.textView.string
                                       forKey:@"props"
                                      onLayer:self.currentLayer
                          forPluginIdentifier:@"com.yy.ued.sketch.components"];
    }
}

- (IBAction)onDiscard:(id)sender {
    [[NSApplication sharedApplication] endModalSession:self.modalSession];
    [self close];
}

@end
