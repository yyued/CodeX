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
        return output;
    },
}

UISegmentedControl.defaultProps = function() {
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
    return code;
}

UISegmentedControl.oc_codeWithProps = function (props) {
    var code = UIView.oc_codeWithProps(props);
    return code;
}