//
//  COMCloudStorager.h
//  components
//
//  Created by 崔明辉 on 2016/12/30.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>

@class COMCloudComponentEntity;

@interface COMCloudOperator : NSObject

+ (void)addComponent:(COMCloudComponentEntity *)component completionBlock:(void(^)())completionBlock;

@end
