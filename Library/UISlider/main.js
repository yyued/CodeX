//
//  UISlider/main.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/12.
//  Copyright © 2016年 UED Center. All rights reserved.
//

var UISlider = {
    parse: function (nodeID, nodeXML, nodeProps) {
        var output = UIView.parse(nodeID, nodeXML, nodeProps);
        var xml = $.create(nodeXML);
        output['tintColor'] = UISlider.findTintColor(nodeID, xml);
        return output;
    },
    findTintColor: function (nodeID, xml) {
        return $(xml).find('#' + nodeID).find('#tintView').attrs('fill', xml);
    },
}

UISlider.defaultProps = function() {
    return Object.assign(UIView.defaultProps(), {
    })
};

UISlider.oc_class = function (props) {
    return "UISlider";
}

UISlider.oc_code = function (props) {
    var code = "";
    code += oc_init("UISlider", "view");
    code += UISlider.oc_codeWithProps(props);
    return code;
}

UISlider.oc_codeWithProps = function (props) {
    var code = UIView.oc_codeWithProps(props);
    if (props.tintColor !== undefined) {
        code += "[view setTintColor:" + oc_color(props.tintColor) + "];\n";
    }
    return code;
}