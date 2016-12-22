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