//
//  COMCloudComponentEntity.h
//  components
//
//  Created by 崔明辉 on 2016/12/30.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface COMCloudComponentEntity : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *zip;
@property (nonatomic, copy) NSArray<NSString *> *dependencies;

@end
