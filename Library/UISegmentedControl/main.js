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
    return code;
}