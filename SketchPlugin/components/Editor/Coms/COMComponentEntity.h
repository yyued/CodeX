//
//  COMComponentEntity.h
//  components
//
//  Created by 崔明辉 on 2016/12/8.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MCSketchPluginFramework/MCSketchPluginFramework.h>

@interface COMComponentEntity : NSObject

@property (nonatomic, copy) NSString *componentName;
@property (nonatomic, strong) NSImage *iconImage;
@property (nonatomic, strong) MSLayer *componentLayer;

- (NSImage *)snapImage;

@end
