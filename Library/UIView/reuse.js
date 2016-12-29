//
//  UIReusableView/main.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/12.
//  Copyright © 2016年 UED Center. All rights reserved.
//

var UIReusableView = {
    parse: function (nodeID, nodeXML, nodeProps) {
        var output = UIView.parse(nodeID, nodeXML, nodeProps);
        var xml = $.create(nodeXML);
        return output;
    },
}

UIReusableView.defaultProps = function () {
    return Object.assign(UIView.defaultProps(), {
        reuseIdentifier: {
            value: undefined,
            type: "String",
        },
        reuseClass: {
            value: "UIView",
            type: "String",
        }
    })
};

UIReusableView.oc_class = function (props) {
    return "UIView";
}

UIReusableView.oc_code = function (props) {
    var code = "";
    code += oc_init("UIView", "view");
    code += UIReusableView.oc_codeWithProps(props);
    return code;
}

UIReusableView.oc_codeWithProps = function (props) {
    var code = UIView.oc_codeWithProps(props);
    return code;
}