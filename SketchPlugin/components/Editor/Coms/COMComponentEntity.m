//
//  COMComponentEntity.m
//  components
//
//  Created by 崔明辉 on 2016/12/8.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMComponentEntity.h"

@implementation COMComponentEntity

- (NSImage *)snapImage {
    MSExportRequest *request = [[MSExportRequest_Class exportRequestsFromExportableLayer:self.componentLayer] firstObject];
    NSString *snapImageFileKey =
    [NSString stringWithFormat:@"/tmp/com.yy.ued.sketch.components/.snap.%@.png",
     [self.componentLayer.name stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
    [[MSDocument_Class currentDocument] saveArtboardOrSlice:request toFile:snapImageFileKey];
    return [[NSImage alloc] initWithContentsOfFile:snapImageFileKey];
}

@end
