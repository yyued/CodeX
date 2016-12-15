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
        if (nodeProps.buttonType === "Text") {
            output["text"] = UILabel.parse(nodeID, nodeXML, {});
        }
        return output;
    },
}

UIButton.defaultProps = function() {
    return Object.assign(UIView.defaultProps(), {
        buttonType: {
            value: ["Text"],
            type: "Enum",
        }
    })
};

UIButton.oc_class = function (props) {
    if (props.buttonType === "Text") {
        return "UIButton";
    }
    return "COXButton";
}

UIButton.oc_code = function (props) {
    var code = "";
    if (props.buttonType === "Text") {
        code += "UIButton *view = [UIButton buttonWithType:UIButtonTypeSystem];\n";
    }
    else {
        code += oc_init("COXButton", "view");
    }
    code += UIButton.oc_codeWithProps(props);
    return code;
}

UIButton.oc_codeWithProps = function (props) {
    var code = UIView.oc_codeWithProps(props);
    if (props.buttonType === "Text") {
        if (props.text !== undefined) {
            code += "{\n";
            code += "    " + oc_init("COXLabel", "titleLabel");
            code += (UILabel.oc_codeWithProps(props.text).replace(/view\./ig, '    titleLabel.').replace(/\[view/ig, '    [titleLabel'));
            code += "    [view setAttributedTitle:titleLabel.attributedText forState:UIControlStateNormal];\n";
            code += "}\n";
        }
    }
    else {

    }
    return code;
}