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

UITextField.xib_code = function (id, layer) {
    var xml = $.xml('<view contentMode="scaleToFill"></view>');
    $(xml).find(':first').attr('id', id);
    $(xml).find(':first').attr('customClass', "COXUITextField");
    UITextField.xib_codeWithProps(id, layer.props, xml);
    UIView.xib_addSublayers(layer, xml);
    return $(xml).html();
}

UITextField.xib_codeWithProps = function (id, props, xml) {
    UIView.xib_codeWithProps(props, xml);
    $(xml).find(':first').find('userDefinedRuntimeAttributes:eq(0)').append('<userDefinedRuntimeAttribute type="boolean" keyPath="clipsToBounds" value="YES"/>');
    if (props.secureField === true) {
        $(xml).find(':first').find('userDefinedRuntimeAttributes:eq(0)').append('<userDefinedRuntimeAttribute type="boolean" keyPath="secureTextEntry" value="YES"/>');
    }
    if (props.leftPadding !== undefined) {
        $(xml).find(':first').find('userDefinedRuntimeAttributes:eq(0)').append('<userDefinedRuntimeAttribute type="number" keyPath="cox_leftPadding"><real key="value" value="' + props.leftPadding + '"/></userDefinedRuntimeAttribute>');
    }
    if (props.text !== undefined) {
        if ($(xml).find(':first').find('subviews').length == 0) {
            $(xml).find(':first').append('<subviews></subviews>');
        }
        $(xml).find(':first').find('subviews:eq(0)').append(
            window["UILabel"].xib_code(id + "-TEXT", {
                class: "UILabel",
                id: id + "-TEXT",
                props: Object.assign(props.text, {tag: -1}),
            })
        )
    }
    if (props.placeholder !== undefined) {
        if ($(xml).find(':first').find('subviews').length == 0) {
            $(xml).find(':first').append('<subviews></subviews>');
        }
        $(xml).find(':first').find('subviews:eq(0)').append(
            window["UILabel"].xib_code(id + "-PLACEHOLDER", {
                class: "UILabel",
                id: id + "-PLACEHOLDER",
                props: Object.assign(props.placeholder, {tag: -2}),
            })
        )
    }
}