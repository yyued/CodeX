//
//  UITextField/main.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/12.
//  Copyright © 2016年 UED Center. All rights reserved.
//

var UITextField = {
    parse: function (nodeID, nodeXML, nodeProps) {
        var output = UIView.parse(nodeID, nodeXML, nodeProps);
        var xml = $.create(nodeXML);
        output["text"] = UILabel.parse(nodeID + ">#Text", nodeXML, {});
        output["placeholder"] = UILabel.parse(nodeID + ">#Placeholder", nodeXML, {});
        var leftPadding = $(xml).find('#' + nodeID + ">#Text").find('tspan:eq(0)').attrs('x');
        if (leftPadding !== undefined) {
            output["leftPadding"] = parseFloat(leftPadding);
            if (isNaN(output["leftPadding"])) {
                delete (output["leftPadding"]);
            }
        }
        return output;
    },
}

UITextField.defaultProps = function () {
    return Object.assign(UIView.defaultProps(), {
        secureField: {
            value: false,
            type: "Bool",
        }
    })
};

UITextField.oc_class = function (props) {
    return "UITextField";
}

UITextField.oc_code = function (props) {
    var code = "";
    code += "UITextField *view = [UITextField new];\nview.clipsToBounds = YES;\n";
    code += UITextField.oc_codeWithProps(props);
    return code;
}

UITextField.oc_codeWithProps = function (props) {
    var code = UIView.oc_codeWithProps(props);
    if (props.text !== undefined) {
        code += "{\n";
        code += "    " + oc_init("COXLabel", "textLabel");
        code += (UILabel.oc_codeWithProps(props.text).replace(/view\./ig, '    textLabel.').replace(/\[view/ig, '    [textLabel'));
        code += "    [view setDefaultTextAttributes:[textLabel defaultAttributes]];\n";
        code += "}\n";
    }
    if (props.placeholder !== undefined) {
        code += "{\n";
        code += "    " + oc_init("COXLabel", "placeholderLabel");
        code += (UILabel.oc_codeWithProps(props.placeholder).replace(/view\./ig, '    placeholderLabel.').replace(/\[view/ig, '    [placeholderLabel'));
        code += "    [view setAttributedPlaceholder:placeholderLabel.attributedText];\n";
        code += "}\n";
    }
    if (props.secureField === true) {
        code += "view.secureTextEntry = YES;\n";
    }
    if (props.leftPadding !== undefined) {
        code += "view.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, " + props.leftPadding + ", 0)];\nview.leftViewMode = UITextFieldViewModeAlways;\n";
    }
    return code;
}