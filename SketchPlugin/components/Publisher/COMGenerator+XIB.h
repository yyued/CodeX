//
//  COMGenerator+XIB.h
//  components
//
//  Created by 崔明辉 on 2016/12/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMGenerator.h"

@interface COMGenerator (XIB)

- (NSDictionary *)xib_code:(COMGenLayer *)layer genType:(COMGenType)genType className:(NSString *)className;

@end
