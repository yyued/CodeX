//
//  UIStatusBar/main.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/12.
//  Copyright © 2016年 UED Center. All rights reserved.
//

var UIStatusBar = {
    parse: function (nodeID, nodeXML, nodeProps) {
        return nodeProps;
    },
}

UIStatusBar.defaultProps = function() {
    return {
        barStyle: {
            value: ["Normal", "Light", "Hidden"],
            type: "Enum",
        }
    }
};

UIStatusBar.oc_load = function (props) {
    var code = "";
    if (props.barStyle === "Light") {
        code += "[self cox_setStatusBarStyle:UIStatusBarStyleLightContent];\n";
    }
    else if (props.barStyle === "Hidden") {
        code += "[self cox_setStatusBarHidden:YES animation:UIStatusBarAnimationNone];\n";
    }
    return code;
}

UIStatusBar.xib_global = function (id, layer, xmlString) {
    var xml = $.xml(xmlString);
    var props = layer.props;
    if (props.barStyle === "Light") {
        $(xml).find('objects').find('placeholder:eq(0)').find('userDefinedRuntimeAttributes:eq(0)').append('<userDefinedRuntimeAttribute type="number" keyPath="cox_statusBarStyle"><integer key="value" value="1"/></userDefinedRuntimeAttribute>');
    }
    else if (props.barStyle === "Hidden") {
        $(xml).find('objects').find('placeholder:eq(0)').find('userDefinedRuntimeAttributes:eq(0)').append('<userDefinedRuntimeAttribute type="boolean" keyPath="cox_statusBarHidden" value="YES"/>');
    }
    xmlString = $(xml).html();
    return xmlString;
}