//
//  UISegmentedControl/main.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/12.
//  Copyright © 2016年 UED Center. All rights reserved.
//

var UISegmentedControl = {
    parse: function (nodeID, nodeXML, nodeProps) {
        var output = UIView.parse(nodeID, nodeXML, nodeProps);
        var xml = $.create(nodeXML);
        var titles = [];
        $(xml).find('#' + nodeID).find('text').each(function () {
            titles.push($(this).find('tspan').text())
        })
        output['titles'] = titles.reverse();
        output['tintColor'] = $(xml).find('#' + nodeID).find('[stroke]:eq(0)').attr('stroke');
        output['selectedColor'] = $(xml).find('#' + nodeID).find('text:eq(' + (titles.length - 2) + ')').attr('fill');
        return output;
    },
}

UISegmentedControl.defaultProps = function () {
    return Object.assign(UIView.defaultProps(), {
        numberOfButtons: {
            value: ["2", "3", "4", "5"],
            type: "Enum",
        }
    })
};

UISegmentedControl.oc_class = function (props) {
    return "UISegmentedControl";
}

UISegmentedControl.oc_code = function (props) {
    var code = "";
    code += oc_init("UISegmentedControl", "view");
    code += UISegmentedControl.oc_codeWithProps(props);
    return code;
}

UISegmentedControl.oc_codeWithProps = function (props) {
    var code = UIView.oc_codeWithProps(props);
    if (props.titles != undefined) {
        for (var index = 0; index < props.titles.length; index++) {
            var element = props.titles[index];
            code += "[view insertSegmentWithTitle:@\"" + oc_text(element) + "\" atIndex:0 animated:NO];\n";
        }
        if (props.titles.length > 0) {
            code += "[view setSelectedSegmentIndex:0];\n";
        }
    }
    if (props.selectedColor != undefined) {
        code += "";
        code += "[view setTitleTextAttributes:@{\n";
        code += "                               NSForegroundColorAttributeName: " + oc_color(props.selectedColor) + ",\n";
        code += "                               }\n";
        code += "                    forState:UIControlStateSelected];\n";
    }
    return code;
}

UISegmentedControl.xib_code = function (id, layer) {
    var xml = $.xml('<view contentMode="scaleToFill"></view>');
    $(xml).find(':first').attr('id', id);
    $(xml).find(':first').attr('customClass', "UISegmentedControl");
    UISegmentedControl.xib_codeWithProps(layer.props, xml);
    UIView.xib_addSublayers(layer, xml);
    return $(xml).html();
}

UISegmentedControl.xib_codeWithProps = function (props, xml) {
    UIView.xib_codeWithProps(props, xml);
    if (props.titles != undefined) {
        $(xml).find(':first').find('userDefinedRuntimeAttributes:eq(0)').append('<userDefinedRuntimeAttribute type="string" keyPath="cox_titles" value="' + props.titles.join(",") + '"/>');
        if (props.titles.length > 0) {
            $(xml).find(':first').find('userDefinedRuntimeAttributes:eq(0)').append('<userDefinedRuntimeAttribute type="number" keyPath="selectedSegmentIndex"><integer key="value" value="0"/></userDefinedRuntimeAttribute>');
        }
    }
    if (props.selectedColor != undefined) {
        $(xml).find(':first').find('userDefinedRuntimeAttributes:eq(0)').append('<userDefinedRuntimeAttribute type="color" keyPath="cox_selectedColor">' + xib_color('value', props.selectedColor) + '</userDefinedRuntimeAttribute>');
    }
}