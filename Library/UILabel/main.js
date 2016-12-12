//
//  UILabel/main.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/12.
//  Copyright © 2016年 UED Center. All rights reserved.
//

var UILabel = {
    parse: function (nodeID, nodeXML, nodeProps) {
        var output = UIView.parse(nodeID, nodeXML, nodeProps);
        var xml = document.createElement('div');
        $(xml).html(nodeXML);
        output["text"] = UILabel.findText(nodeID, xml);
        output["fontFamily"] = $(xml).find('#' + nodeID).attrs('font-family', xml);
        output["fontSize"] = $(xml).find('#' + nodeID).attrs('font-size', xml) && parseFloat($(xml).find('#' + nodeID).attrs('font-size', xml));
        output["underline"] = $(xml).find('#' + nodeID).attrs('text-decoration', xml) === "underline";
        output["deleteline"] = $(xml).find('#' + nodeID).attrs('text-decoration', xml) === "line-through";
        output["letterSpacing"] = $(xml).find('#' + nodeID).attrs('letter-spacing', xml) && parseFloat($(xml).find('#' + nodeID).attrs('letter-spacing', xml));
        output["lineSpacing"] = $(xml).find('#' + nodeID).attrs('line-spacing', xml) && (parseFloat($(xml).find('#' + nodeID).attrs('line-spacing', xml)) / 2.0);
        output["textColor"] = $(xml).find('#' + nodeID).attrs('fill', xml);
        output["strokeWidth"] = $(xml).find('#' + nodeID).attrs('stroke-width', xml) && (parseFloat($(xml).find('#' + nodeID).attrs('stroke-width', xml)) * 2.0);
        output["strokeColor"] = $(xml).find('#' + nodeID).attrs('stroke', xml);
        if (output["strokeColor"] === "none") {
            output["strokeWidth"] = undefined;
            output["strokeColor"] = undefined;
        }
        return output;
    },
    findText: function (nodeID, xml) {
        var text = "";
        $(xml).find('#' + nodeID).find('tspan').each(function () {
            text += $(this).text();
        });
        return text;
    },
}

UILabel.oc_class = function (props) {
    return "COXLabel";
}

UILabel.oc_code = function (props) {
    var code = "";
    code += oc_init("COXLabel", "view");
    code += UILabel.oc_codeWithProps(props);
    return code;
}

UILabel.oc_codeWithProps = function (props) {
    var code = UIView.oc_codeWithProps(props);
    if (props.fontFamily !== undefined && props.fontSize !== undefined) {
        code += "[view setFontWithFamilyName:@\"" + props.fontFamily + "\" fontSize:" + props.fontSize + "];\n";
    }
    else if (props.fontSize !== undefined) {
        code += "view.font = [UIFont systemFontOfSize:"+props.fontSize+"];\n";
    }
    if (props.textColor !== undefined) {
        code += "view.textColor = " + oc_color(props.textColor) + ";\n";
    }
    if (props.strokeColor !== undefined) {
        code += "view.strokeColor = " + oc_color(props.strokeColor) + ";\n"; 
    }
    if (props.strokeWidth !== undefined) {
        code += "view.strokeWidth = " + props.strokeWidth + ";\n"; 
    }
    if (props.deleteline !== undefined && props.deleteline == true) {
        code += "view.deletelineStyle = NSUnderlineStyleSingle;\n"; 
    }
    if (props.underline !== undefined && props.underline == true) {
        code += "view.underlineStyle = NSUnderlineStyleSingle;\n"; 
    }
    if (props.letterSpacing !== undefined) {
        code += "view.letterSpace = " + props.letterSpacing + ";\n"; 
    }
    if (props.lineSpacing !== undefined) {
        code += "view.lineSpacing = " + props.lineSpacing + ";\n"; 
    }
    if (props.numberOfLines !== undefined) {
        code += "view.numberOfLines = " + props.numberOfLines + ";\n";
    }
    if (props.text !== undefined) {
        code += "view.text = @\"" + oc_text(props.text) + "\";\n";
    }
    return code;
}