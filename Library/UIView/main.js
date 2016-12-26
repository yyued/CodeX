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
        output['borderOpacity'] = $(xml).find('#' + nodeID).find('#Bounds').attrs('stroke-opacity', xml) && parseFloat($(xml).find('#' + nodeID).find('#Bounds').attrs('stroke-opacity', xml));
        output['borderWidth'] = $(xml).find('#' + nodeID).find('#Bounds').attrs('stroke-width', xml) && (parseFloat($(xml).find('#' + nodeID).find('#Bounds').attrs('stroke-width', xml)) / 1.0);
        if (output['borderColor'] === "none") {
            output['borderColor'] = undefined;
        }
        if (output['borderColor'] !== undefined) {
            if (output['borderOpacity'] !== undefined) {
                output['borderColor'] = colorWithAlpha(output['borderColor'], output['borderOpacity']);
            }
            if (output['borderWidth'] === undefined) {
                output['borderWidth'] = 1.0;
            }
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
        adjustFrame: {
            value: false,
            type: "Bool",
        },
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
    if (props.adjustFrame === true) {
        code += "view.cox_automaticallyAdjustsSpace = YES;\n";
    }
    return code;
}

UIView.xib_code = function (id, layer) {
    var xml = $.xml('<view contentMode="scaleToFill"></view>');
    $(xml).find(':first').attr('id', id);
    $(xml).find(':first').attr('customClass', "UIView");
    UIView.xib_codeWithProps(layer.props, xml);
    if (layer.sublayers !== undefined && layer.sublayers.length > 0) {
        $(xml).find(':first').append('<subviews></subviews>');
        for (var index = 0; index < layer.sublayers.length; index++) {
            var sublayer = layer.sublayers[index];
            if (window[sublayer.class] !== undefined && window[sublayer.class].xib_code !== undefined) {
                $(xml).find(':first').find('subviews').append(
                    window[sublayer.class].xib_code(sublayer.id, sublayer)
                )
            }
        }
    }
    return $(xml).html();
}

UIView.xib_codeWithProps = function (props, xml) {
    $(xml).find(':first').append('<userDefinedRuntimeAttributes></userDefinedRuntimeAttributes>')
    if (props.tag !== undefined) {
        $(xml).find(':first').attr('tag', props.tag);
    }
    if (props.frame !== undefined) {
        $(xml).find(':first').append('<rect key="frame" x="' + props.frame.x + '" y="' + props.frame.y + '" width="' + props.frame.width + '" height="' + props.frame.height + '"/>');
    }
    if (props.alpha !== undefined) {
        $(xml).find(':first').attr('alpha', props.alpha);
    }
    if (props.backgroundColor !== undefined && oc_color(props.backgroundColor) != "nil") {
        $(xml).find(':first').append(xib_color('backgroundColor', props.backgroundColor));
    }
    else if (props['outletID'] === "rootView") {
        $(xml).find(':first').append(xib_color('backgroundColor', '#ffffff'));
    }
    else {
        $(xml).find(':first').append(xib_color('backgroundColor', '#00000000'));
    }
    if (props.cornerRadius !== undefined) {
        $(xml).find(':first').find('userDefinedRuntimeAttributes').append('<userDefinedRuntimeAttribute type="number" keyPath="layer.cornerRadius"><real key="value" value="' + props.cornerRadius + '"/></userDefinedRuntimeAttribute>');
    }
    if (props.masksToBounds === true) {
        $(xml).find(':first').find('userDefinedRuntimeAttributes').append('<userDefinedRuntimeAttribute type="boolean" keyPath="layer.masksToBounds" value="YES"/>');
    }
    if (props.borderColor !== undefined && oc_color(props.borderColor) != "nil") {
        $(xml).find(':first').find('userDefinedRuntimeAttributes').append('<userDefinedRuntimeAttribute type="color" keyPath="cox_borderColor">' + xib_color('value', props.borderColor) + '</userDefinedRuntimeAttribute>');
    }
    if (props.borderWidth !== undefined) {
        $(xml).find(':first').find('userDefinedRuntimeAttributes').append('<userDefinedRuntimeAttribute type="number" keyPath="layer.borderWidth"><real key="value" value="' + props.borderWidth + '"/></userDefinedRuntimeAttribute>');
    }
    if (props.tintColor !== undefined) {
        $(xml).find(':first').append(xib_color('tintColor', props.backgroundColor));
    }
    if (props.constraints !== undefined) {
        $(xml).find(':first').find('userDefinedRuntimeAttributes').append('<userDefinedRuntimeAttribute type="boolean" keyPath="cox_constraintEnabled" value="YES"/>');
        if (props.constraints.centerRelativeTo == 2) {
            $(xml).find(':first').find('userDefinedRuntimeAttributes').append('<userDefinedRuntimeAttribute type="number" keyPath="cox_constraint.aligmentRelate"><integer key="value" value="1"/></userDefinedRuntimeAttribute>');
        }
        if (props.constraints.centerHorizontally == 1) {
            $(xml).find(':first').find('userDefinedRuntimeAttributes').append('<userDefinedRuntimeAttribute type="boolean" keyPath="cox_constraint.centerHorizontally" value="YES"/>');
        }
        if (props.constraints.centerVertically == 1) {
            $(xml).find(':first').find('userDefinedRuntimeAttributes').append('<userDefinedRuntimeAttribute type="boolean" keyPath="cox_constraint.centerVertically" value="YES"/>');
        }
        if (props.constraints.sizeRelativeTo == 2) {
            $(xml).find(':first').find('userDefinedRuntimeAttributes').append('<userDefinedRuntimeAttribute type="number" keyPath="cox_constraint.sizeRelate"><integer key="value" value="1"/></userDefinedRuntimeAttribute>');
        }
        if (props.constraints.useFixedWidth == 1 && props.constraints.fixedWidth !== undefined) {
            $(xml).find(':first').find('userDefinedRuntimeAttributes').append('<userDefinedRuntimeAttribute type="string" keyPath="cox_constraint.width" value="' + props.constraints.fixedWidth + '"/>');
        }
        if (props.constraints.useFixedHeight == 1 && props.constraints.fixedHeight !== undefined) {
            $(xml).find(':first').find('userDefinedRuntimeAttributes').append('<userDefinedRuntimeAttribute type="string" keyPath="cox_constraint.height" value="' + props.constraints.fixedHeight + '"/>');
        }
        if (props.constraints.pinRelativeTo == 2) {
            $(xml).find(':first').find('userDefinedRuntimeAttributes').append('<userDefinedRuntimeAttribute type="number" keyPath="cox_constraint.pinRelate"><integer key="value" value="1"/></userDefinedRuntimeAttribute>');
        }
        if (props.constraints.useTopPinning == 1 && props.constraints.topPinning !== undefined) {
            $(xml).find(':first').find('userDefinedRuntimeAttributes').append('<userDefinedRuntimeAttribute type="string" keyPath="cox_constraint.top" value="' + props.constraints.topPinning + '"/>');
        }
        if (props.constraints.useLeftPinning == 1 && props.constraints.leftPinning !== undefined) {
            $(xml).find(':first').find('userDefinedRuntimeAttributes').append('<userDefinedRuntimeAttribute type="string" keyPath="cox_constraint.left" value="' + props.constraints.leftPinning + '"/>');
        }
        if (props.constraints.useBottomPinning == 1 && props.constraints.bottomPinning !== undefined) {
            $(xml).find(':first').find('userDefinedRuntimeAttributes').append('<userDefinedRuntimeAttribute type="string" keyPath="cox_constraint.bottom" value="' + props.constraints.bottomPinning + '"/>');
        }
        if (props.constraints.useRightPinning == 1 && props.constraints.rightPinning !== undefined) {
            $(xml).find(':first').find('userDefinedRuntimeAttributes').append('<userDefinedRuntimeAttribute type="string" keyPath="cox_constraint.right" value="' + props.constraints.rightPinning + '"/>');
        }
    }
    if (props.adjustFrame === true) {
        $(xml).find(':first').find('userDefinedRuntimeAttributes').append('<userDefinedRuntimeAttribute type="boolean" keyPath="cox_automaticallyAdjustsSpace" value="YES"/>');
    }
}