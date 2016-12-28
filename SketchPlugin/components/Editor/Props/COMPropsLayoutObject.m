//
//  COMPropsLayoutObject.m
//  components
//
//  Created by 崔明辉 on 2016/12/23.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMPropsLayoutObject.h"
#import <MCSketchPluginFramework/MCSketchPluginFramework.h>

@implementation COMPropsLayoutObject

- (void)loadLayout {
    MSLayer *layer = [Sketch_GetSelectedLayers(Sketch_GetCurrentDocument()) firstObject];
    if (layer != nil) {
        NSDictionary *layoutAttrs = [[MSPluginCommand_Class new] valueForKey:@"constraints"
                                                                     onLayer:layer
                                                         forPluginIdentifier:@"com.matt-curtis.sketch.constraints"];
        if ([layoutAttrs[@"centerRelativeTo"] isEqualToNumber:@(2)]) {
            [self.viewController.alignmentRelative setSelectedSegment:1];
        } else {
            [self.viewController.alignmentRelative setSelectedSegment:0];
        }
        if ([layoutAttrs[@"centerHorizontally"] isEqualToNumber:@(1)]) {
            self.viewController.centerHCheckbox.state = 1;
        } else {
            self.viewController.centerHCheckbox.state = 0;
        }
        if ([layoutAttrs[@"centerVertically"] isEqualToNumber:@(1)]) {
            self.viewController.centerVCheckbox.state = 1;
        } else {
            self.viewController.centerVCheckbox.state = 0;
        }
        if ([layoutAttrs[@"sizeRelativeTo"] isEqualToNumber:@(2)]) {
            [self.viewController.sizeRelative setSelectedSegment:1];
        } else {
            [self.viewController.sizeRelative setSelectedSegment:0];
        }
        if ([layoutAttrs[@"useFixedWidth"] isEqualToNumber:@(1)]) {
            self.viewController.widthCheckbox.state = 1;
        } else {
            self.viewController.widthCheckbox.state = 0;
        }
        if ([layoutAttrs[@"useFixedHeight"] isEqualToNumber:@(1)]) {
            self.viewController.heightCheckbox.state = 1;
        } else {
            self.viewController.heightCheckbox.state = 0;
        }
        if ([layoutAttrs[@"fixedWidth"] isKindOfClass:[NSString class]]) {
            [self.viewController.widthTextField setStringValue:layoutAttrs[@"fixedWidth"]];
        } else {
            [self.viewController.widthTextField setStringValue:@""];
        }
        if ([layoutAttrs[@"fixedHeight"] isKindOfClass:[NSString class]]) {
            [self.viewController.heightTextField setStringValue:layoutAttrs[@"fixedHeight"]];
        } else {
            [self.viewController.heightTextField setStringValue:@""];
        }
        if ([layoutAttrs[@"pinRelativeTo"] isEqualToNumber:@(2)]) {
            [self.viewController.pinRelative setSelectedSegment:1];
        } else {
            [self.viewController.pinRelative setSelectedSegment:0];
        }
        if ([layoutAttrs[@"useTopPinning"] isEqualToNumber:@(1)]) {
            self.viewController.topCheckbox.state = 1;
        } else {
            self.viewController.topCheckbox.state = 0;
        }
        if ([layoutAttrs[@"topPinning"] isKindOfClass:[NSString class]]) {
            [self.viewController.topTextField setStringValue:layoutAttrs[@"topPinning"]];
        } else {
            [self.viewController.topTextField setStringValue:@""];
        }
        if ([layoutAttrs[@"useLeftPinning"] isEqualToNumber:@(1)]) {
            self.viewController.leftCheckbox.state = 1;
        } else {
            self.viewController.leftCheckbox.state = 0;
        }
        if ([layoutAttrs[@"leftPinning"] isKindOfClass:[NSString class]]) {
            [self.viewController.leftTextField setStringValue:layoutAttrs[@"leftPinning"]];
        } else {
            [self.viewController.leftTextField setStringValue:@""];
        }
        if ([layoutAttrs[@"useBottomPinning"] isEqualToNumber:@(1)]) {
            self.viewController.bottomCheckbox.state = 1;
        } else {
            self.viewController.bottomCheckbox.state = 0;
        }
        if ([layoutAttrs[@"bottomPinning"] isKindOfClass:[NSString class]]) {
            [self.viewController.bottomTextField setStringValue:layoutAttrs[@"bottomPinning"]];
        } else {
            [self.viewController.bottomTextField setStringValue:@""];
        }
        if ([layoutAttrs[@"useRightPinning"] isEqualToNumber:@(1)]) {
            self.viewController.rightCheckbox.state = 1;
        } else {
            self.viewController.rightCheckbox.state = 0;
        }
        if ([layoutAttrs[@"rightPinning"] isKindOfClass:[NSString class]]) {
            [self.viewController.rightTextField setStringValue:layoutAttrs[@"rightPinning"]];
        } else {
            [self.viewController.rightTextField setStringValue:@""];
        }
    }
}

- (void)saveLayout {
    NSDictionary *attrs = @{
        @"centerRelativeTo" : self.viewController.alignmentRelative.selectedSegment == 0 ? @(1) : @(2),
        @"centerHorizontally" : @(self.viewController.centerHCheckbox.state),
        @"centerVertically" : @(self.viewController.centerVCheckbox.state),
        @"sizeRelativeTo" : self.viewController.sizeRelative.selectedSegment == 0 ? @(1) : @(2),
        @"useFixedWidth" : @(self.viewController.widthCheckbox.state),
        @"useFixedHeight" : @(self.viewController.heightCheckbox.state),
        @"fixedWidth" : self.viewController.widthTextField.stringValue,
        @"fixedHeight" : self.viewController.heightTextField.stringValue,
        @"pinRelativeTo" : self.viewController.pinRelative.selectedSegment == 0 ? @(1) : @(2),
        @"useTopPinning" : @(self.viewController.topCheckbox.state),
        @"topPinning" : self.viewController.topTextField.stringValue,
        @"useLeftPinning" : @(self.viewController.leftCheckbox.state),
        @"leftPinning" : self.viewController.leftTextField.stringValue,
        @"useBottomPinning" : @(self.viewController.bottomCheckbox.state),
        @"bottomPinning" : self.viewController.bottomTextField.stringValue,
        @"useRightPinning" : @(self.viewController.rightCheckbox.state),
        @"rightPinning" : self.viewController.rightTextField.stringValue,
    };
    [Sketch_GetSelectedLayers(Sketch_GetCurrentDocument())
        enumerateObjectsUsingBlock:^(id _Nonnull layer, NSUInteger idx, BOOL *_Nonnull stop) {
          [[MSPluginCommand_Class new] setValue:attrs
                                         forKey:@"constraints"
                                        onLayer:layer
                            forPluginIdentifier:@"com.matt-curtis.sketch.constraints"];
          [[MSPluginCommand_Class new] setValue:attrs
                                         forKey:@"constraints"
                                        onLayer:layer
                            forPluginIdentifier:@"com.yy.ued.sketch.components"];
        }];
}

- (IBAction)onLayoutCheckboxChanged:(id)sender {
    [self saveLayout];
}

- (IBAction)onLayoutClearButtonClicked:(id)sender {
    [Sketch_GetSelectedLayers(Sketch_GetCurrentDocument())
        enumerateObjectsUsingBlock:^(id _Nonnull layer, NSUInteger idx, BOOL *_Nonnull stop) {
          [[MSPluginCommand_Class new] setValue:@{}
                                         forKey:@"constraints"
                                        onLayer:layer
                            forPluginIdentifier:@"com.matt-curtis.sketch.constraints"];
          [[MSPluginCommand_Class new] setValue:@{}
                                         forKey:@"constraints"
                                        onLayer:layer
                            forPluginIdentifier:@"com.yy.ued.sketch.components"];
        }];
    [self loadLayout];
}

#pragma mark - Auto fill layout value.

- (void)autofillWidth {
    MSLayer *layer = [self findCurrent];
    self.viewController.widthCheckbox.state = 1;
    if ([self.viewController.widthTextField.stringValue containsString:@"%"] ||
        self.viewController.widthTextField.stringValue.length == 0) {
        [self.viewController.widthTextField setStringValue:[NSString stringWithFormat:@"%ld", (long)layer.frame.width]];
    } else {
        if (layer.parentGroup == nil) {
            return;
        }
        if (self.viewController.sizeRelative.selectedSegment == 0) {
            CGFloat percentage = layer.frame.width / layer.parentGroup.frame.width * 100;
            [self.viewController.widthTextField setStringValue:[NSString stringWithFormat:@"%ld%%", (long)percentage]];
        } else if (self.viewController.sizeRelative.selectedSegment == 1) {
            MSLayer *previousLayer = [self findPrevious];
            if (previousLayer != nil) {
                CGFloat percentage = layer.frame.width / previousLayer.frame.width * 100;
                [self.viewController.widthTextField
                    setStringValue:[NSString stringWithFormat:@"%ld%%", (long)percentage]];
            }
        }
    }
    [self saveLayout];
}

- (void)autofillHeight {
    MSLayer *layer = [self findCurrent];
    self.viewController.heightCheckbox.state = 1;
    if ([self.viewController.heightTextField.stringValue containsString:@"%"] ||
        self.viewController.heightTextField.stringValue.length == 0) {
        [self.viewController.heightTextField
            setStringValue:[NSString stringWithFormat:@"%ld", (long)layer.frame.height]];
    } else {
        if (layer.parentGroup == nil) {
            return;
        }
        if (self.viewController.sizeRelative.selectedSegment == 0) {
            CGFloat percentage = layer.frame.height / layer.parentGroup.frame.height * 100;
            [self.viewController.heightTextField setStringValue:[NSString stringWithFormat:@"%ld%%", (long)percentage]];
        } else if (self.viewController.sizeRelative.selectedSegment == 1) {
            MSLayer *previousLayer = [self findPrevious];
            if (previousLayer != nil) {
                CGFloat percentage = layer.frame.height / previousLayer.frame.height * 100;
                [self.viewController.heightTextField
                    setStringValue:[NSString stringWithFormat:@"%ld%%", (long)percentage]];
            }
        }
    }
    [self saveLayout];
}

- (void)autofillTop {
    MSLayer *layer = [self findCurrent];
    if (layer.parentGroup == nil) {
        return;
    }
    self.viewController.topCheckbox.state = 1;
    if (self.viewController.pinRelative.selectedSegment == 1 &&
        ![self.viewController.topTextField.stringValue containsString:@"%"] &&
        [self findPrevious] != nil) {
        CGFloat constant = layer.frame.y - ([self findPrevious].frame.y + [self findPrevious].frame.height);
        [self.viewController.topTextField setStringValue:[NSString stringWithFormat:@"100%%+(%ld)", (long)constant]];
        [self saveLayout];
        return;
    }
    if (self.viewController.centerVCheckbox.state == 1) {
        if (self.viewController.alignmentRelative.selectedSegment == 0) {
            // C -> Group(V)
            CGFloat constant = layer.frame.y - (layer.parentGroup.frame.height / 2.0 - layer.frame.height / 2.0);
            [self.viewController.topTextField setStringValue:[NSString stringWithFormat:@"%ld", (long)constant]];
        }
        else if (self.viewController.alignmentRelative.selectedSegment == 1) {
            // C -> Previous(V)
            MSLayer *previousLayer = [self findPrevious];
            CGFloat constant = (layer.frame.y + layer.frame.height / 2.0) - (previousLayer.frame.y + previousLayer.frame.height / 2.0);
            if (previousLayer != nil) {
                [self.viewController.topTextField
                 setStringValue:[NSString stringWithFormat:@"%ld", (long)constant]];
            }
        }
    } else {
        if (self.viewController.pinRelative.selectedSegment == 0) {
            // C -> Group
            [self.viewController.topTextField
             setStringValue:[NSString stringWithFormat:@"%ld", (long)layer.frame.y]];
        } else if (self.viewController.pinRelative.selectedSegment == 1) {
            // C -> Previous
            MSLayer *previousLayer = [self findPrevious];
            if (previousLayer != nil) {
                [self.viewController.topTextField
                 setStringValue:[NSString
                                 stringWithFormat:@"%ld", (long)(layer.frame.y - previousLayer.frame.y)]];
            }
        }
    }
    [self saveLayout];
}

- (void)autofillLeft {
    MSLayer *layer = [self findCurrent];
    if (layer.parentGroup == nil) {
        return;
    }
    self.viewController.leftCheckbox.state = 1;
    if (self.viewController.pinRelative.selectedSegment == 1 &&
        ![self.viewController.leftTextField.stringValue containsString:@"%"] &&
        [self findPrevious] != nil) {
        CGFloat constant = layer.frame.x - ([self findPrevious].frame.x + [self findPrevious].frame.width);
        [self.viewController.leftTextField setStringValue:[NSString stringWithFormat:@"100%%+(%ld)", (long)constant]];
        [self saveLayout];
        return;
    }
    if (self.viewController.centerHCheckbox.state == 1) {
        if (self.viewController.alignmentRelative.selectedSegment == 0) {
            // C -> Group(V)
            CGFloat constant = layer.frame.x - (layer.parentGroup.frame.width / 2.0 - layer.frame.width / 2.0);
            [self.viewController.leftTextField setStringValue:[NSString stringWithFormat:@"%ld", (long)constant]];
        }
        else if (self.viewController.alignmentRelative.selectedSegment == 1) {
            // C -> Previous(V)
            MSLayer *previousLayer = [self findPrevious];
            CGFloat constant = (layer.frame.x + layer.frame.width / 2.0) - (previousLayer.frame.x + previousLayer.frame.width / 2.0);
            if (previousLayer != nil) {
                [self.viewController.leftTextField
                 setStringValue:[NSString stringWithFormat:@"%ld", (long)constant]];
            }
        }
    } else {
        if (self.viewController.pinRelative.selectedSegment == 0) {
            // C -> Group
            [self.viewController.leftTextField
             setStringValue:[NSString stringWithFormat:@"%ld", (long)layer.frame.x]];
        } else if (self.viewController.pinRelative.selectedSegment == 1) {
            // C -> Previous
            MSLayer *previousLayer = [self findPrevious];
            if (previousLayer != nil) {
                [self.viewController.leftTextField
                 setStringValue:[NSString
                                 stringWithFormat:@"%ld", (long)(layer.frame.x - previousLayer.frame.x)]];
            }
        }
    }
    [self saveLayout];
}

- (void)autofillBottom {
    MSLayer *layer = [self findCurrent];
    if (layer.parentGroup == nil) {
        return;
    }
    self.viewController.bottomCheckbox.state = 1;
    if (self.viewController.pinRelative.selectedSegment == 1 &&
        ![self.viewController.bottomTextField.stringValue containsString:@"%"] &&
        [self findPrevious] != nil) {
        CGFloat constant = [self findPrevious].frame.y - (layer.frame.y + layer.frame.height);
        [self.viewController.bottomTextField setStringValue:[NSString stringWithFormat:@"100%%+(%ld)", (long)constant]];
        [self saveLayout];
        return;
    }
    if (self.viewController.centerVCheckbox.state == 1) {
        if (self.viewController.alignmentRelative.selectedSegment == 0) {
            // C -> Group(V)
            CGFloat constant = (layer.parentGroup.frame.height / 2.0 + layer.frame.height / 2.0) - (layer.frame.y + layer.frame.height);
            [self.viewController.bottomTextField setStringValue:[NSString stringWithFormat:@"%ld", (long)constant]];
        }
        else if (self.viewController.alignmentRelative.selectedSegment == 1) {
            // C -> Previous(V)
            MSLayer *previousLayer = [self findPrevious];
            CGFloat constant = (previousLayer.frame.y + previousLayer.frame.height) - (layer.frame.y + layer.frame.height);
            if (previousLayer != nil) {
                [self.viewController.bottomTextField
                 setStringValue:[NSString stringWithFormat:@"%ld", (long)constant]];
            }
        }
    } else {
        if (self.viewController.pinRelative.selectedSegment == 0) {
            // C -> Group
            CGFloat constant = (layer.parentGroup.frame.height - (layer.frame.y + layer.frame.height));
            [self.viewController.bottomTextField
             setStringValue:[NSString stringWithFormat:@"%ld", (long) constant]];
        } else if (self.viewController.pinRelative.selectedSegment == 1) {
            // C -> Previous
            MSLayer *previousLayer = [self findPrevious];
            CGFloat constant = ((previousLayer.frame.y + previousLayer.frame.height) - (layer.frame.y + layer.frame.height));
            if (previousLayer != nil) {
                [self.viewController.bottomTextField
                 setStringValue:[NSString stringWithFormat:@"%ld", (long)constant]];
            }
        }
    }
    [self saveLayout];
}

- (void)autofillRight {
    MSLayer *layer = [self findCurrent];
    if (layer.parentGroup == nil) {
        return;
    }
    self.viewController.rightCheckbox.state = 1;
    if (self.viewController.pinRelative.selectedSegment == 1 &&
        ![self.viewController.rightTextField.stringValue containsString:@"%"] &&
        [self findPrevious] != nil) {
        CGFloat constant = [self findPrevious].frame.x - (layer.frame.x + layer.frame.width);
        [self.viewController.rightTextField setStringValue:[NSString stringWithFormat:@"100%%+(%ld)", (long)constant]];
        [self saveLayout];
        return;
    }
    if (self.viewController.centerHCheckbox.state == 1) {
        if (self.viewController.alignmentRelative.selectedSegment == 0) {
            // C -> Group(V)
            CGFloat constant = (layer.parentGroup.frame.width / 2.0 + layer.frame.width / 2.0) - (layer.frame.x + layer.frame.width);
            [self.viewController.rightTextField setStringValue:[NSString stringWithFormat:@"%ld", (long)constant]];
        }
        else if (self.viewController.alignmentRelative.selectedSegment == 1) {
            // C -> Previous(V)
            MSLayer *previousLayer = [self findPrevious];
            CGFloat constant = (previousLayer.frame.x + previousLayer.frame.width) - (layer.frame.x + layer.frame.width);
            if (previousLayer != nil) {
                [self.viewController.rightTextField
                 setStringValue:[NSString stringWithFormat:@"%ld", (long)constant]];
            }
        }
    } else {
        if (self.viewController.pinRelative.selectedSegment == 0) {
            // C -> Group
            CGFloat constant = (layer.parentGroup.frame.width - (layer.frame.x + layer.frame.width));
            [self.viewController.rightTextField
             setStringValue:[NSString stringWithFormat:@"%ld", (long) constant]];
        } else if (self.viewController.pinRelative.selectedSegment == 1) {
            // C -> Previous
            MSLayer *previousLayer = [self findPrevious];
            CGFloat constant = ((previousLayer.frame.x + previousLayer.frame.width) - (layer.frame.x + layer.frame.width));
            if (previousLayer != nil) {
                [self.viewController.rightTextField
                 setStringValue:[NSString stringWithFormat:@"%ld", (long)constant]];
            }
        }
    }
    [self saveLayout];
}

- (MSLayer *)findCurrent {
    return [Sketch_GetSelectedLayers(Sketch_GetCurrentDocument()) firstObject];
}

- (MSLayer *)findPrevious {
    MSLayer *layer = [Sketch_GetSelectedLayers(Sketch_GetCurrentDocument()) firstObject];
    MSLayer *previousLayer;
    for (MSLayer *sublayer in layer.parentGroup.layers) {
        if (sublayer == layer) {
            break;
        } else {
            previousLayer = sublayer;
        }
    }
    return previousLayer;
}

@end
