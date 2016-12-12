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

var oc_color = function (hexColor) {
    hexColor = hexColor.replace('#', '').trim();
    if (hexColor.length == 6) {
        var r = hexColor.substring(0, 2);
        var g = hexColor.substring(2, 4);
        var b = hexColor.substring(4, 6);
        return "[UIColor colorWithRed:0x" + r + "/255.0 green:0x" + g + "/255.0 blue:0x" + b + "/255.0 alpha:1.0]"
    }
    else if (hexColor.length == 8) {
        var a = hexColor.substring(0, 2);
        var r = hexColor.substring(2, 4);
        var g = hexColor.substring(4, 6);
        var b = hexColor.substring(6, 8);
        return "[UIColor colorWithRed:0x" + r + "/255.0 green:0x" + g + "/255.0 blue:0x" + b + "/255.0 alpha:0x" + a + "/255.0]"
    }
    return "nil";
}

var oc_text = function (text) {
    return text.replace(/"/ig, '\"');
}