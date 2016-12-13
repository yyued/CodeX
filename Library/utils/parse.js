//
//  utils/parse.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/13.
//  Copyright © 2016年 UED Center. All rights reserved.
//

var colorWithAlpha = function(hexColor, alpha) {
    _hexColor = hexColor.replace('#', '').trim();
    if (_hexColor.length == 6) {
        var a = parseInt(alpha * 255).toString(16);
        if (a.length == 1) {
            a = "0" + a;
        }
        var r = _hexColor.substring(0, 2);
        var g = _hexColor.substring(2, 4);
        var b = _hexColor.substring(4, 6);
        return "#" + a + r + g + b;
    }
    else if (_hexColor.length == 8) {
        var a = parseInt(alpha * 255).toString(16);
        if (a.length == 1) {
            a = "0" + a;
        }
        var r = _hexColor.substring(2, 4);
        var g = _hexColor.substring(4, 6);
        var b = _hexColor.substring(6, 8);
        return "#" + a + r + g + b;
    }
    return hexColor;
}