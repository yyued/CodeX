//
//  UINavigationBar/main.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/12.
//  Copyright © 2016年 UED Center. All rights reserved.
//

var UINavigationBar = {
    parse: function (nodeID, nodeXML, nodeProps) {
        return nodeProps;
    },
}

UINavigationBar.defaultProps = function() {
    return {
        titleView: {
            value: ["Title", "Title_SubTitle", "SegmentedControl", "Image"],
            type: "Enum",
        }
    }
};

UINavigationBar.oc_class = function (props) {
    return "";
}

UINavigationBar.oc_code = function (props) {
    return "";
}

UINavigationBar.oc_codeWithProps = function (props) {
    return "";
}