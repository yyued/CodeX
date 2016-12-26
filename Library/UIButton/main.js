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

UIButton.defaultProps = function () {
    return Object.assign(UIView.defaultProps(), {
        buttonType: {
            value: ["Text"],
            type: "Enum",
        }
    })
};

UIButton.oc_class = function (props) {
    return "UIButton";
}

UIButton.oc_code = function (props) {
    var code = "";
    code += "UIButton *view = [UIButton buttonWithType:UIButtonTypeSystem];\n";
    code += UIButton.oc_codeWithProps(props);
    return code;
}

UIButton.oc_codeWithProps = function (props) {
    var code = UIView.oc_codeWithProps(props);
    if (props.text !== undefined) {
        code += "{\n";
        code += "    " + oc_init("COXLabel", "titleLabel");
        code += (UILabel.oc_codeWithProps(props.text).replace(/view\./ig, '    titleLabel.').replace(/\[view/ig, '    [titleLabel'));
        code += "    [view setAttributedTitle:titleLabel.attributedText forState:UIControlStateNormal];\n";
        code += "}\n";
    }
    return code;
}

UIButton.xib_code = function (id, layer) {
    var xml = $.xml('<view contentMode="scaleToFill"></view>');
    $(xml).find(':first').attr('id', id);
    $(xml).find(':first').attr('customClass', "COXUIButton");
    UIButton.xib_codeWithProps(id, layer.props, xml);
    return $(xml).html();
}

UIButton.xib_codeWithProps = function (id, props, xml) {
    UIView.xib_codeWithProps(props, xml);
    if (props.text !== undefined) {
        if ($(xml).find(':first').find('subviews').length == 0) {
            $(xml).find(':first').append('<subviews></subviews>');
        }
        $(xml).find(':first').find('subviews').append(
            window["UILabel"].xib_code(id + "-TEXT", {
                class: "UILabel",
                id: id + "-TEXT",
                props: Object.assign(props.text, {tag: -1}),
            })
        )
    }
}