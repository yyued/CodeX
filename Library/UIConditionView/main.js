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
        "where_x=0": {
            value: undefined,
            type: "Layer",
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

UIConditionView.xib_code = function (id, layer) {
    var xml = $.xml('<view contentMode="scaleToFill"></view>');
    $(xml).find(':first').attr('id', id);
    $(xml).find(':first').attr('customClass', "COXConditionView");
    UIConditionView.xib_codeWithProps(layer.props, xml);
    UIView.xib_addSublayers(layer, xml);
    return $(xml).html();
}

UIConditionView.xib_codeWithProps = function (props, xml) {
    UIView.xib_codeWithProps(props, xml);
}