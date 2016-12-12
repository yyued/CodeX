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
        var xml = document.createElement('div');
        $(xml).html(nodeXML);
        output['frame'] = UIView.findFrame(nodeID, xml);
        output['alpha'] = $(xml).find('#' + nodeID).attrs('opacity', xml) && parseFloat($(xml).find('#' + nodeID).attrs('opacity', xml));
        output['backgroundColor'] = $(xml).find('#' + nodeID).find('#Bounds').attrs('fill', xml);
        output['cornerRadius'] = $(xml).find('#' + nodeID).find('#Bounds').attrs('rx', xml) && parseFloat($(xml).find('#' + nodeID).find('#Bounds').attrs('rx', xml));
        output['borderColor'] = $(xml).find('#' + nodeID).find('#Bounds').attrs('stroke', xml);
        output['borderWidth'] = $(xml).find('#' + nodeID).find('#Bounds').attrs('stroke-width', xml) && (parseFloat($(xml).find('#' + nodeID).find('#Bounds').attrs('stroke-width', xml)) / 2.0);
        if (output['borderColor'] !== undefined && output['borderWidth'] === undefined) {
            output['borderWidth'] = 1.0;
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
    if (props.backgroundColor !== undefined) {
        code += "view.backgroundColor = " + oc_color(props.backgroundColor) + ";\n";
    }
    if (props.cornerRadius !== undefined) {
        code += "view.layer.cornerRadius = " + props.cornerRadius + ";\n"
    }
    if (props.borderColor !== undefined) {
        code += "view.layer.borderColor = " + oc_color(props.borderColor) + ".CGColor;\n"
    }
    if (props.borderWidth !== undefined) {
        code += "view.layer.borderWidth = " + props.borderWidth + ";\n"
    }
    if (props.constraints !== undefined) {
        var constraints = "";
        for (var key in props.constraints) {
            if (props.constraints.hasOwnProperty(key)) {
                var element = props.constraints[key];
                constraints += "    @\"" + key + "\"" + ": @\"" + element + "\",\n";
            }
        }
        code += "view.cox_constraints = @{\n" + constraints + "};\n";
    }
    return code;
}