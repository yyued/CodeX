//
//  UISwitch/main.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/9.
//  Copyright © 2016年 UED Center. All rights reserved.
//

var UISwitch = {
    parse: function (nodeID, nodeXML, nodeProps) {
        var output = UIView.parse(nodeID, nodeXML, nodeProps);
        var xml = document.createElement('div');
        $(xml).html(nodeXML);
        output['onTintColor'] = UISwitch.findOnTintColor(nodeID, xml);
        return output;
    },
    findOnTintColor: function (nodeID, xml) {
        return $(xml).find('#' + nodeID).find('#onBackground').attrs('fill', xml);
    },
}

UISwitch.defaultProps = function() {
    return Object.assign(UIView.defaultProps(), {
    })
};

UISwitch.oc_class = function (props) {
    return "UISwitch";
}

UISwitch.oc_code = function (props) {
    var code = "";
    code += oc_init("UISwitch", "view");
    code += UISwitch.oc_codeWithProps(props);
    return code;
}

UISwitch.oc_codeWithProps = function (props) {
    var code = UIView.oc_codeWithProps(props);
    if (props.onTintColor !== undefined) {
        code += "[view setOnTintColor:" + oc_color(props.onTintColor) + "];\n";
    }
    return code;
}

UISwitch.xib_code = function (id, layer) {
    var xml = $.xml('<switch contentMode="scaleToFill"></switch>');
    $(xml).find(':first').attr('id', id);
    $(xml).find(':first').attr('customClass', "UISwitch");
    UISwitch.xib_codeWithProps(layer.props, xml);
    UIView.xib_addSublayers(layer, xml);
    return $(xml).html();
}

UISwitch.xib_codeWithProps = function (props, xml) {
    UIView.xib_codeWithProps(props, xml);
    if (props.onTintColor !== undefined) {
        $(xml).find(':first').append(xib_color('onTintColor', props.onTintColor));
    }
}