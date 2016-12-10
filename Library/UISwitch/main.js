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