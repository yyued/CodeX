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

COXButton.xib_code = function (id, layer) {
    var xml = $.xml('<view contentMode="scaleToFill"></view>');
    $(xml).find(':first').attr('id', id);
    $(xml).find(':first').attr('customClass', "COXButton");
    COXButton.xib_codeWithProps(layer.props, xml);
    UIView.xib_addSublayers(layer, xml);
    return $(xml).html();
}

COXButton.xib_codeWithProps = function (props, xml) {
    UIConditionView.xib_codeWithProps(props, xml);
    if (props.animated === true) {
        $(xml).find(':first').find('userDefinedRuntimeAttributes:eq(0)').append('<userDefinedRuntimeAttribute type="boolean" keyPath="animated" value="YES"/>');
    }
}