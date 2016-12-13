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
        var xml = $.create(nodeXML);
        output["text"] = UILabel.findText(nodeID, xml);
        Object.assign(output, UILabel.findFirstTextAttributes(nodeID, xml));
        Object.assign(output, UILabel.findShadow(nodeID, xml));
        output["rangeAttrs"] = UILabel.findRangeTextAttributes(nodeID, xml, output);
        return output;
    },
    findFirstTextAttributes: function (nodeID, xml) {
        var firstText;
        var use = false;
        $(xml).find('#' + nodeID).find('use').each(function () {
            if ($(this).attrs('filter', xml) !== undefined) {
                return;
            }
            use = true;
            firstText = $(this).find('tspan')[0];
        });
        if (!use) {
            firstText = $(xml).find('#' + nodeID).find('tspan')[0];
        }
        if (firstText !== undefined) {
            var output = {};
            output["fontFamily"] = $(firstText).attrs('font-family', xml);
            output["fontSize"] = $(firstText).attrs('font-size', xml) && parseFloat($(firstText).attrs('font-size', xml));
            output["underline"] = $(firstText).attrs('text-decoration', xml) === "underline";
            output["deleteline"] = $(firstText).attrs('text-decoration', xml) === "line-through";
            output["letterSpacing"] = $(firstText).attrs('letter-spacing', xml) && parseFloat($(firstText).attrs('letter-spacing', xml));
            output["lineSpacing"] = $(firstText).attrs('line-spacing', xml) && (parseFloat($(firstText).attrs('line-spacing', xml)) / 2.0);
            output["textColor"] = $(firstText).attrs('fill', xml);
            output["strokeWidth"] = $(firstText).attrs('stroke-width', xml) && (parseFloat($(firstText).attrs('stroke-width', xml)) * 2.0);
            output["strokeColor"] = $(firstText).attrs('stroke', xml);
            if (output["strokeColor"] === "none") {
                output["strokeWidth"] = undefined;
                output["strokeColor"] = undefined;
            }
            return output;
        }
        return {};
    },
    findRangeTextAttributes: function (nodeID, xml, standardAttrs) {
        var rangeAttrs = [];
        var currentRange = {
            location: 0,
            length: 0,
        };
        var use = false;
        for (var index = 0; index < $(xml).find('#' + nodeID).find('use').length; index++) {
            var element = $(xml).find('#' + nodeID).find('use')[index];
            if ($(element).attrs('filter', xml) !== undefined) {
                continue;
            }
            use = true;
            $(element).find('tspan').each(function () {
                var item = {};
                var cRange = {}
                currentRange.location += currentRange.length;
                currentRange.length = $(this).text().length;
                cRange.location = currentRange.location;
                cRange.length = currentRange.length;
                if ($(this).attrs('font-family', xml) !== standardAttrs["fontFamily"]) {
                    item["fontFamily"] = $(this).attrs('font-family', xml);
                }
                if (($(this).attrs('font-size', xml) && parseFloat($(this).attrs('font-size', xml))) !== standardAttrs["fontSize"]) {
                    item["fontSize"] = ($(this).attrs('font-size', xml) && parseFloat($(this).attrs('font-size', xml)));
                }
                if (($(this).attrs('text-decoration', xml) === "underline") !== standardAttrs["underline"]) {
                    item["underline"] = $(this).attrs('text-decoration', xml) === "underline";
                }
                if (($(this).attrs('text-decoration', xml) === "line-through") !== standardAttrs["deleteline"]) {
                    item["deleteline"] = $(this).attrs('text-decoration', xml) === "line-through";
                }
                if (($(this).attrs('letter-spacing', xml) && parseFloat($(this).attrs('letter-spacing', xml))) !== standardAttrs["letterSpacing"]) {
                    item["letterSpacing"] = ($(this).attrs('letter-spacing', xml) && parseFloat($(this).attrs('letter-spacing', xml)));
                }
                if (($(this).attrs('line-spacing', xml) && (parseFloat($(this).attrs('line-spacing', xml)) / 2.0)) !== standardAttrs["lineSpacing"]) {
                    item["lineSpacing"] = ($(this).attrs('line-spacing', xml) && (parseFloat($(this).attrs('line-spacing', xml)) / 2.0));
                }
                if ($(this).attrs('fill', xml) !== standardAttrs["textColor"]) {
                    item["textColor"] = $(this).attrs('fill', xml);
                }
                if (Object.keys(item).length > 0) {
                    item.range = cRange;
                    rangeAttrs.push(item);
                }
            });
        }
        if (!use) {
            $(xml).find('#' + nodeID).find('tspan').each(function () {
                var item = {};
                var cRange = {}
                currentRange.location += currentRange.length;
                currentRange.length = $(this).text().length;
                cRange.location = currentRange.location;
                cRange.length = currentRange.length;
                if ($(this).attrs('font-family', xml) !== standardAttrs["fontFamily"]) {
                    item["fontFamily"] = $(this).attrs('font-family', xml);
                }
                if (($(this).attrs('font-size', xml) && parseFloat($(this).attrs('font-size', xml))) !== standardAttrs["fontSize"]) {
                    item["fontSize"] = ($(this).attrs('font-size', xml) && parseFloat($(this).attrs('font-size', xml)));
                }
                if (($(this).attrs('text-decoration', xml) === "underline") !== standardAttrs["underline"]) {
                    item["underline"] = $(this).attrs('text-decoration', xml) === "underline";
                }
                if (($(this).attrs('text-decoration', xml) === "line-through") !== standardAttrs["deleteline"]) {
                    item["deleteline"] = $(this).attrs('text-decoration', xml) === "line-through";
                }
                if (($(this).attrs('letter-spacing', xml) && parseFloat($(this).attrs('letter-spacing', xml))) !== standardAttrs["letterSpacing"]) {
                    item["letterSpacing"] = ($(this).attrs('letter-spacing', xml) && parseFloat($(this).attrs('letter-spacing', xml)));
                }
                if (($(this).attrs('line-spacing', xml) && (parseFloat($(this).attrs('line-spacing', xml)) / 2.0)) !== standardAttrs["lineSpacing"]) {
                    item["lineSpacing"] = ($(this).attrs('line-spacing', xml) && (parseFloat($(this).attrs('line-spacing', xml)) / 2.0));
                }
                if ($(this).attrs('fill', xml) !== standardAttrs["textColor"]) {
                    item["textColor"] = $(this).attrs('fill', xml);
                }
                if (Object.keys(item).length > 0) {
                    item.range = cRange;
                    rangeAttrs.push(item);
                }
            });
        }
        return rangeAttrs;
    },
    findText: function (nodeID, xml) {
        var text = "";
        var use = false;
        for (var index = 0; index < $(xml).find('#' + nodeID).find('use').length; index++) {
            var element = $(xml).find('#' + nodeID).find('use')[index];
            if ($(element).attrs('filter', xml) !== undefined) {
                continue;
            }
            use = true;
            $(element).find('tspan').each(function () {
                text += $(this).text();
            });
        }
        if (!use) {
            $(xml).find('#' + nodeID).find('tspan').each(function () {
                text += $(this).text();
            });
        }
        return text;
    },
    findShadow: function (nodeID, xml) {
        var output = {};
        $(xml).find('#' + nodeID).find('use').each(function () {
            if ($(this).attr('filter') !== undefined) {
                var filterID = $(this).attr('filter').replace(/url\((.*?)\)/, "$1");
                var filterNode = $(xml).find(filterID);
                var dx = $(filterNode).find('feOffset').attr('dx') ? parseFloat($(filterNode).find('feOffset').attr('dx')) : 0;
                var dy = $(filterNode).find('feOffset').attr('dy') ? parseFloat($(filterNode).find('feOffset').attr('dy')) : 0;
                output["shadowOffset"] = {
                    x: dx,
                    y: dy,
                }
                output["shadowRadius"] = $(filterNode).find('feGaussianBlur').attr('stdDeviation') ? parseFloat($(filterNode).find('feGaussianBlur').attr('stdDeviation')) : 0;
                var colorMatrix = $(filterNode).find("feColorMatrix").attr("values");
                if (colorMatrix !== undefined) {
                    output["shadowColor"] = UILabel.convertColorMatrixToHex(colorMatrix);
                }
            }
        })
        return output;
    },
    convertColorMatrixToHex: function (feColor) {
        var rows = feColor.split("  ");
        if (rows.length == 4) {
            var r = 0.0;
            var g = 0.0;
            var b = 0.0;
            var a = 1.0;
            for (var index = 0; index < rows.length; index++) {
                var row = rows[index];
                var columns = row.split(" ");
                switch (index) {
                    case 0:
                        r = parseFloat(columns[4]);
                        break;
                    case 1:
                        g = parseFloat(columns[4]);
                        break;
                    case 2:
                        b = parseFloat(columns[4]);
                        break;
                    case 3:
                        a = parseFloat(columns[3]);
                        break;
                }
            }
            var ahex = parseInt(a * 255).toString(16);
            var rhex = parseInt(r * 255).toString(16);
            var ghex = parseInt(g * 255).toString(16);
            var bhex = parseInt(b * 255).toString(16);
            if (ahex.length == 1) { ahex = "0" + ahex; }
            if (rhex.length == 1) { rhex = "0" + rhex; }
            if (ghex.length == 1) { ghex = "0" + ghex; }
            if (bhex.length == 1) { bhex = "0" + bhex; }
            return "#" + ahex + rhex + ghex + bhex;
        }
        return "";
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
        code += "view.font = [UIFont systemFontOfSize:" + props.fontSize + "];\n";
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
    if (props.shadowColor !== undefined) {
        code += "view.layer.shadowColor = " + oc_color(props.shadowColor) + ".CGColor;\nview.layer.shadowOpacity = 1.0;\n";
    }
    if (props.shadowOffset !== undefined) {
        code += "view.layer.shadowOffset = CGSizeMake(" + props.shadowOffset.x + ", " + props.shadowOffset.y + ");\n";
    }
    if (props.shadowRadius !== undefined) {
        code += "view.layer.shadowRadius = " + props.shadowRadius + ";\n";
    }
    if (props.maxWidth !== undefined && props.maxWidth > 0) {
        code += "view.maxWidth = " + props.maxWidth + ";\n";
    }
    if (props.alignment !== undefined) {
        if (props.alignment == 0) {
            code += "view.textAlignment = NSTextAlignmentLeft;\n";
        }
        else if (props.alignment == 2) {
            code += "view.textAlignment = NSTextAlignmentCenter;\n";
        }
        else if (props.alignment == 1) {
            code += "view.textAlignment = NSTextAlignmentRight;\n";
        }
    }
    if (props.text !== undefined) {
        code += "view.text = @\"" + oc_text(props.text) + "\";\n";
    }
    if (props.rangeAttrs !== undefined) {
        for (var index = 0; index < props.rangeAttrs.length; index++) {
            var element = props.rangeAttrs[index];
            var rangeCode = "{\n    COXLabel *rView = [view copy];\n"
            rangeCode += (UILabel.oc_codeWithProps(element).replace(/view\./ig, '    rView.').replace(/\[view/ig, '    [rView'));
            rangeCode += "    [view setAttributesWithRange:NSMakeRange(" + element.range.location + ", " + element.range.length + ") referenceLabel:rView];\n";
            rangeCode += "}\n"
            code += rangeCode;
        }
    }
    return code;
}