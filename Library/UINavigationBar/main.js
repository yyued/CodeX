//
//  UINavigationBar/main.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/12.
//  Copyright © 2016年 UED Center. All rights reserved.
//

var UINavigationBar = {
    parse: function (nodeID, nodeXML, nodeProps) {
        var output = nodeProps;
        var xml = $.create(nodeXML);
        if (nodeProps.titleView === "Title") {
            output["titleText"] = $(xml).find('#Title').find('tspan').text();
        }
        return output;
    },
}

UINavigationBar.defaultProps = function () {
    return {
        titleView: {
            value: ["Title", "Title_SubTitle", "SegmentedControl", "Image"],
            type: "Enum",
        }
    }
};

UINavigationBar.oc_viewDidLoad = function (props) {
    if (props.titleView === "Title" && props.titleText !== undefined) {
        return "self.title = @\"" + oc_text(props.titleText) + "\";\n";
    }
    return undefined;
}