//
//  UIPixelLine/main.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/12.
//  Copyright © 2016年 UED Center. All rights reserved.
//

var UIPixelLine = {
    parse: function (nodeID, nodeXML, nodeProps) {
        var output = UIView.parse(nodeID, nodeXML, nodeProps);
        var xml = $.create(nodeXML);
        output["color"] = $(xml).find("#" + nodeID).attrs('stroke', xml);
        var opacity = $(xml).find("#" + nodeID).attrs('stroke-opacity', xml) && parseFloat($(xml).find("#" + nodeID).attrs('stroke-opacity', xml));
        if (opacity !== undefined) {
            output["color"] = colorWithAlpha(output["color"], opacity);
        }
        return output;
    },
}

UIPixelLine.defaultProps = function () {
    return Object.assign(UIView.defaultProps(), {
        dimension: {
            value: ["Horizon", "Vertical"],
            type: "Enum",
        }
    })
};

UIPixelLine.oc_class = function (props) {
    return "COXPixelLine";
}

UIPixelLine.oc_code = function (props) {
    var code = "";
    code += "COXPixelLine *view = [COXPixelLine new];\n";
    code += UIPixelLine.oc_codeWithProps(props);
    return code;
}

UIPixelLine.oc_codeWithProps = function (props) {
    var code = UIView.oc_codeWithProps(props);
    if (props.color !== undefined) {
        code += "view.color = " + oc_color(props.color) + ";\n";
    }
    if (props.dimension !== undefined) {
        code += "view.vertical = " + (props.dimension === "Vertical" ? "YES" : "NO") + ";\n";
    }
    return code;
}