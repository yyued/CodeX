//
//  UIView/main.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/9.
//  Copyright © 2016年 UED Center. All rights reserved.
//

var COXButton = {
    parse: function (nodeID, nodeXML, nodeProps) {
        var output = UIConditionView.parse(nodeID, nodeXML, nodeProps);
        var xml = $.create(nodeXML);
        return output;
    },
}

COXButton.defaultProps = function () {
    var obj = Object.assign(UIConditionView.defaultProps(), {
        "where_Normal=0": {
            value: undefined,
            type: "Layer",
        },
        "where_Highlighted=1": {
            value: undefined,
            type: "Layer",
        },
        "where_Selected=4": {
            value: undefined,
            type: "Layer",
        },
        "where_Disabled=2": {
            value: undefined,
            type: "Layer",
        },
        "where_Selected_Highlighted=5": {
            value: undefined,
            type: "Layer",
        },
        animated: {
            value: false,
            type: "Bool",
        }
    });
    delete obj["where_x=0"];
    return obj;
};

COXButton.oc_class = function (props) {
    return "COXButton";
}

COXButton.oc_code = function (props) {
    var code = "";
    code += oc_init("COXButton", "view");
    code += COXButton.oc_codeWithProps(props);
    return code;
}

COXButton.oc_codeWithProps = function (props) {
    var code = UIConditionView.oc_codeWithProps(props);
    if (props.animated === true) {
        code += "view.animated = YES;\n";
    }
    return code;
}