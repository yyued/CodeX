//
//  COMComponentSourceEntity.h
//  components
//
//  Created by 崔明辉 on 2016/12/8.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "COMComponentEntity.h"

@interface COMComponentSourceEntity : NSObject

@property (nonatomic, copy) NSString *sourceName;
@property (nonatomic, copy) NSArray<COMComponentEntity *> *components;

- (NSArray *)categories;

@end
