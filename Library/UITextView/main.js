//
//  UITextView/main.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/12.
//  Copyright © 2016年 UED Center. All rights reserved.
//

var UITextView = {
    parse: function (nodeID, nodeXML, nodeProps) {
        var output = UIView.parse(nodeID, nodeXML, nodeProps);
        var xml = $.create(nodeXML);
        output["text"] = UILabel.parse(nodeID + ">#Text", nodeXML, {});
        var inset = $(xml).find('#' + nodeID + ">#Text").find('tspan:eq(0)').attrs('x');
        if (inset !== undefined) {
            output["inset"] = parseFloat(inset);
            if (isNaN(output["inset"])) {
                delete (output["inset"]);
            }
        }
        return output;
    },
}

UITextView.defaultProps = function () {
    return Object.assign(UIView.defaultProps(), {
    })
};

UITextView.oc_viewDidLoad = function (props) {
    return "self.automaticallyAdjustsScrollViewInsets = NO;\n";
}

UITextView.oc_class = function (props) {
    return "UITextView";
}

UITextView.oc_code = function (props) {
    var code = "";
    code += "UITextView *view = [UITextView new];\nview.clipsToBounds = YES;\n";
    code += UITextView.oc_codeWithProps(props);
    return code;
}

UITextView.oc_codeWithProps = function (props) {
    var code = UIView.oc_codeWithProps(props);
    if (props.text !== undefined) {
        code += "{\n";
        code += "    " + oc_init("COXLabel", "textLabel");
        code += "    textLabel.lineBreakMode = NSLineBreakByWordWrapping;\n";
        code += (UILabel.oc_codeWithProps(props.text).replace(/view\./ig, '    textLabel.').replace(/\[view/ig, '    [textLabel'));
        code += "    [view setAttributedText:textLabel.attributedText];\n    [view setTypingAttributes:[textLabel defaultAttributes]];\n";
        code += "}\n";
    }
    if (props.inset !== undefined) {
        code += "[view setTextContainerInset:UIEdgeInsetsMake(" + props.inset + ", " + (props.inset - 4) + ", " + props.inset + ", " + (props.inset - 4) + ")];\n";
    }
    return code;
}

UITextView.xib_code = function (id, layer) {
    var xml = $.xml('<view contentMode="scaleToFill"></view>');
    $(xml).find(':first').attr('id', id);
    $(xml).find(':first').attr('customClass', "COXUITextView");
    UITextView.xib_codeWithProps(id, layer.props, xml);
    UIView.xib_addSublayers(layer, xml);
    return $(xml).html();
}

UITextView.xib_codeWithProps = function (id, props, xml) {
    UIView.xib_codeWithProps(props, xml);
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
    if (props.inset !== undefined) {
        $(xml).find(':first').find('userDefinedRuntimeAttributes:eq(0)').append('<userDefinedRuntimeAttribute type="number" keyPath="cox_inset"><real key="value" value="' + props.inset + '"/></userDefinedRuntimeAttribute>');
    }
}