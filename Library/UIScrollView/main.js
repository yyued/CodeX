//
//  UIScrollView/main.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/12.
//  Copyright © 2016年 UED Center. All rights reserved.
//

var UIScrollView = {
    parse: function (nodeID, nodeXML, nodeProps) {
        var output = UIView.parse(nodeID, nodeXML, nodeProps);
        var xml = $.create(nodeXML);
        return output;
    },
}

UIScrollView.defaultProps = function () {
    return Object.assign(UIView.defaultProps(), {
        contentWidth: {
            value: undefined,
            type: "Number",
        },
        contentHeight: {
            value: undefined,
            type: "Number",
        },
        adjustInset: {
            value: false,
            type: "Bool",
        },
    })
};

UIScrollView.oc_viewDidLoad = function(props) {
    if (props.adjustInset === true) {
        return "self.automaticallyAdjustsScrollViewInsets = YES;\n";
    }
    else {
        return "self.automaticallyAdjustsScrollViewInsets = NO;\n";
    }
}

UIScrollView.oc_class = function (props) {
    return "UIScrollView";
}

UIScrollView.oc_code = function (props) {
    var code = "";
    code += oc_init("UIScrollView", "view");
    code += UIScrollView.oc_codeWithProps(props);
    return code;
}

UIScrollView.oc_codeWithProps = function (props) {
    var code = UIView.oc_codeWithProps(props);
    var contentWidth = props.contentWidth != undefined ? parseFloat(props.contentWidth) : 0.0;
    var contentHeight = props.contentHeight != undefined ? parseFloat(props.contentHeight) : 0.0;
    if (isNaN(contentWidth)) contentWidth = 0.0;
    if (isNaN(contentHeight)) contentHeight = 0.0;
    code += "view.contentSize = CGSizeMake(" + contentWidth + ", " + contentHeight + ");\n";
    return code;
}

UIScrollView.xib_code = function (id, layer) {
    var xml = $.xml('<view contentMode="scaleToFill"></view>');
    $(xml).find(':first').attr('id', id);
    $(xml).find(':first').attr('customClass', "UIScrollView");
    UIScrollView.xib_codeWithProps(layer.props, xml);
    UIView.xib_addSublayers(layer, xml);
    return $(xml).html();
}

UIScrollView.xib_codeWithProps = function (props, xml) {
    UIView.xib_codeWithProps(props, xml);
    var contentWidth = props.contentWidth != undefined ? parseFloat(props.contentWidth) : 0.0;
    var contentHeight = props.contentHeight != undefined ? parseFloat(props.contentHeight) : 0.0;
    if (isNaN(contentWidth)) contentWidth = 0.0;
    if (isNaN(contentHeight)) contentHeight = 0.0;
    $(xml).find(':first').find('userDefinedRuntimeAttributes:eq(0)').append('<userDefinedRuntimeAttribute type="size" keyPath="contentSize"><size key="value" width="' + contentWidth + '" height="' + contentHeight + '"/></userDefinedRuntimeAttribute>');
}