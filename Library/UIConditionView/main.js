//
//  UIView/main.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/9.
//  Copyright © 2016年 UED Center. All rights reserved.
//

var UIConditionView = {
    parse: function (nodeID, nodeXML, nodeProps) {
        var output = UIView.parse(nodeID, nodeXML, nodeProps);
        var xml = $.create(nodeXML);
        return output;
    },
}

UIConditionView.defaultProps = function () {
    return Object.assign(UIView.defaultProps(), {
        whereXXX: {
            value: undefined,
            type: "String",
        },
    })
};

UIConditionView.oc_class = function (props) {
    return "COXConditionView";
}

UIConditionView.oc_code = function (props) {
    var code = "";
    code += oc_init("COXConditionView", "view");
    code += UIConditionView.oc_codeWithProps(props);
    return code;
}

UIConditionView.oc_codeWithProps = function (props) {
    return UIView.oc_codeWithProps(props);
}