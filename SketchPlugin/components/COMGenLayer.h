//
//  COMGenLayer.h
//  components
//
//  Created by 崔明辉 on 2016/12/9.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface COMGenLayer : NSObject

@property (nonatomic, copy) NSString *layerID;
@property (nonatomic, copy) NSString *layerClass;
@property (nonatomic, copy) NSDictionary *props;
@property (nonatomic, copy) NSArray<COMGenLayer *> *sublayers;

@end
