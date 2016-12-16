//
//  UIView/main.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/9.
//  Copyright © 2016年 UED Center. All rights reserved.
//

var UIView = {
    parse: function (nodeID, nodeXML, nodeProps) {
        var output = Object.assign({}, nodeProps);
        var xml = $.create(nodeXML);
        output['frame'] = UIView.findFrame(nodeID, xml);
        output['alpha'] = $(xml).find('#' + nodeID).attrs('opacity', xml) && parseFloat($(xml).find('#' + nodeID).attrs('opacity', xml));
        output['backgroundColor'] = $(xml).find('#' + nodeID).find('#Bounds').attrs('fill', xml);
        var fillOpacity = $(xml).find('#' + nodeID).find('#Bounds').attrs('fill-opacity', xml) && parseFloat($(xml).find('#' + nodeID).find('#Bounds').attrs('fill-opacity', xml));
        if (output['backgroundColor'] !== undefined && fillOpacity !== undefined) {
            output['backgroundColor'] = colorWithAlpha(output['backgroundColor'], fillOpacity);
        }
        output['cornerRadius'] = $(xml).find('#' + nodeID).find('#Bounds').attrs('rx', xml) && parseFloat($(xml).find('#' + nodeID).find('#Bounds').attrs('rx', xml));
        output['borderColor'] = $(xml).find('#' + nodeID).find('#Bounds').attrs('stroke', xml);
        output['borderWidth'] = $(xml).find('#' + nodeID).find('#Bounds').attrs('stroke-width', xml) && (parseFloat($(xml).find('#' + nodeID).find('#Bounds').attrs('stroke-width', xml)) / 2.0);
        if (output['borderColor'] === "none") {
            output['borderColor'] = undefined;
        }
        if (output['borderColor'] !== undefined && output['borderWidth'] === undefined) {
            output['borderWidth'] = 1.0;
        }
        if (output['borderColor'] === undefined) {
            output['borderWidth'] = undefined;
        }
        if ($(xml).find('#' + nodeID).find('mask').length > 0) {
            output['masksToBounds'] = true;
        }
        return output;
    },
    findFrame: function (nodeID, xml) {
        var parseTransform = function (a) {
            var b = {};
            for (var i in a = a.match(/(\w+\((\-?\d+\.?\d*e?\-?\d*,?)+\))+/g)) {
                var c = a[i].match(/[\w\.\-]+/g);
                b[c.shift()] = c;
            }
            return b;
        };
        var frame = {
            x: 0,
            y: 0,
            width: 0,
            height: 0,
        }
        var bounds = $(xml).find('#' + nodeID).find('#Bounds');
        if (bounds !== undefined) {
            if (bounds.attrs('width', xml) !== undefined) {
                frame.width = parseFloat(bounds.attrs('width', xml));
            }
            if (bounds.attrs('height', xml) !== undefined) {
                frame.height = parseFloat(bounds.attrs('height', xml));
            }
        }
        var transform = $(xml).find('#' + nodeID).attrs('transform', xml);
        if (transform !== undefined) {
            transform = transform.replace(/ /ig, '');
            var translate = parseTransform(transform)['translate'];
            if (translate !== undefined) {
                frame.x = parseFloat(translate[0]);
                frame.y = parseFloat(translate[1]);
            }
        }
        return frame;
    },
}

UIView.defaultProps = function () {
    return {
        outletID: {
            value: undefined,
            type: "String",
        },
        autoAdjust: {
            value: false,
            type: "Bool",
        }
    }
}

UIView.oc_class = function (props) {
    return "UIView";
}

UIView.oc_code = function (props) {
    var code = "";
    code += oc_init("UIView", "view");
    code += UIView.oc_codeWithProps(props);
    return code;
}

UIView.oc_codeWithProps = function (props) {
    var code = "";
    if (props.tag !== undefined) {
        code += "view.tag = " + parseInt(props.tag) + ";\n";
    }
    if (props.frame !== undefined) {
        code += "view.frame = CGRectMake(" + props.frame.x + "," + props.frame.y + "," + props.frame.width + "," + props.frame.height + ");\n";
    }
    if (props.alpha !== undefined) {
        code += "view.alpha = " + props.alpha + ";\n";
    }
    if (props.backgroundColor !== undefined && oc_color(props.backgroundColor) != "nil") {
        code += "view.backgroundColor = " + oc_color(props.backgroundColor) + ";\n";
    }
    if (props.cornerRadius !== undefined) {
        code += "view.layer.cornerRadius = " + props.cornerRadius + ";\n";
    }
    if (props.masksToBounds === true) {
        code += "view.layer.masksToBounds = YES;\n";
    }
    if (props.borderColor !== undefined && oc_color(props.borderColor) != "nil") {
        code += "view.layer.borderColor = " + oc_color(props.borderColor) + ".CGColor;\n";
    }
    if (props.borderWidth !== undefined) {
        code += "view.layer.borderWidth = " + props.borderWidth + ";\n";
    }
    if (props.tintColor !== undefined) {
        code += "view.tintColor = " + oc_color(props.tintColor) + ";\n";
    }
    if (props.constraints !== undefined) {
        code += "view.cox_constraint = [COXConstraint new];\n";
        if (props.constraints.centerRelativeTo == 2) {
            code += "view.cox_constraint.aligmentRelate = COXLayoutRelateToPrevious;\n";
        }
        if (props.constraints.centerHorizontally == 1) {
            code += "view.cox_constraint.centerHorizontally = YES;\n";
        }
        if (props.constraints.centerVertically == 1) {
            code += "view.cox_constraint.centerVertically = YES;\n";
        }
        if (props.constraints.sizeRelativeTo == 2) {
            code += "view.cox_constraint.sizeRelate = COXLayoutRelateToPrevious;\n";
        }
        if (props.constraints.useFixedWidth == 1 && props.constraints.fixedWidth !== undefined) {
            code += "view.cox_constraint.width = @\"" + props.constraints.fixedWidth + "\";\n";
        }
        if (props.constraints.useFixedHeight == 1 && props.constraints.fixedHeight !== undefined) {
            code += "view.cox_constraint.height = @\"" + props.constraints.fixedHeight + "\";\n";
        }
        if (props.constraints.pinRelativeTo == 2) {
            code += "view.cox_constraint.pinRelate = COXLayoutRelateToPrevious;\n";
        }
        if (props.constraints.useTopPinning == 1 && props.constraints.topPinning !== undefined) {
            code += "view.cox_constraint.top = @\"" + props.constraints.topPinning + "\";\n";
        }
        if (props.constraints.useLeftPinning == 1 && props.constraints.leftPinning !== undefined) {
            code += "view.cox_constraint.left = @\"" + props.constraints.leftPinning + "\";\n";
        }
        if (props.constraints.useBottomPinning == 1 && props.constraints.bottomPinning !== undefined) {
            code += "view.cox_constraint.bottom = @\"" + props.constraints.bottomPinning + "\";\n";
        }
        if (props.constraints.useRightPinning == 1 && props.constraints.rightPinning !== undefined) {
            code += "view.cox_constraint.right = @\"" + props.constraints.rightPinning + "\";\n";
        }
    }
    if (props.autoAdjust === true) {
        code += "view.cox_automaticallyAdjustsSpace = YES;\n";
    }
    return code;
}