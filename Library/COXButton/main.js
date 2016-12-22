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
    return Object.assign(UIConditionView.defaultProps(), {
        "where_Normal=0": {
            value: undefined,
            type: "String",
        },
        "where_Highlighted=1": {
            value: undefined,
            type: "String",
        },
        "where_Selected=4": {
            value: undefined,
            type: "String",
        },
        "where_Disabled=2": {
            value: undefined,
            type: "String",
        },
        "where_Selected_Highlighted=5": {
            value: undefined,
            type: "String",
        },
    })
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
    return UIConditionView.oc_codeWithProps(props);
}