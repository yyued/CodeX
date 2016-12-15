//
//  UIStatusBar/main.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/12.
//  Copyright © 2016年 UED Center. All rights reserved.
//

var UIStatusBar = {
    parse: function (nodeID, nodeXML, nodeProps) {
        return nodeProps;
    },
}

UIStatusBar.defaultProps = function() {
    return {
        barStyle: {
            value: ["Normal", "Light"],
            type: "Enum",
        }
    }
};

UIStatusBar.oc_class = function (props) {
    return "";
}

UIStatusBar.oc_code = function (props) {
    return "";
}

UIStatusBar.oc_codeWithProps = function (props) {
    return "";
}