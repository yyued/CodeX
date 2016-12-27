//
//  COMGenerator+OC.h
//  components
//
//  Created by 崔明辉 on 2016/12/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMGenerator.h"

@interface COMGenerator (OC)

- (NSDictionary *)oc_code:(COMGenLayer *)layer genType:(COMGenType)genType;

@end
