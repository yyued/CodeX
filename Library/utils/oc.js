//
//  utils/oc.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/9.
//  Copyright © 2016年 UED Center. All rights reserved.
//

var oc_init = function (className, propName) {
    return className + " *" + propName + " = [" + className + " new];\n";
}