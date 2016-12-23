//
//  utils/xib.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/23.
//  Copyright © 2016年 UED Center. All rights reserved.
//


var xib_color = function (aKey, hexColor) {
    hexColor = hexColor.replace('#', '').trim();
    var r = 0.0;
    var g = 0.0;
    var b = 0.0;
    var a = 1.0;
    if (hexColor.length == 6) {
        r = parseInt(hexColor.substring(0, 2), 16) / 255.0;
        g = parseInt(hexColor.substring(2, 4), 16) / 255.0;
        b = parseInt(hexColor.substring(4, 6), 16) / 255.0;
    }
    else if (hexColor.length == 8) {
        a = parseInt(hexColor.substring(0, 2), 16) / 255.0;
        r = parseInt(hexColor.substring(2, 4), 16) / 255.0;
        g = parseInt(hexColor.substring(4, 6), 16) / 255.0;
        b = parseInt(hexColor.substring(6, 8), 16) / 255.0;
    }
    return '<color key="' + aKey + '" red="' + r + '" green="' + g + '" blue="' + b + '" alpha="' + a + '" colorSpace="calibratedRGB"/>';
}