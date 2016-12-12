//
//  UIButton/main.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/12.
//  Copyright © 2016年 UED Center. All rights reserved.
//

var UIButton = {
    parse: function (nodeID, nodeXML, nodeProps) {
        var output = UIView.parse(nodeID, nodeXML, nodeProps);
        var xml = $.create(nodeXML);
        return output;
    },
}

UIButton.oc_class = function (props) {
    return "UIButton";
}

UIButton.oc_code = function (props) {
    var code = "";
    code += oc_init("UIButton", "view");
    code += UIButton.oc_codeWithProps(props);
    return code;
}

UIButton.oc_codeWithProps = function (props) {
    var code = UIView.oc_codeWithProps(props);
    return code;
}