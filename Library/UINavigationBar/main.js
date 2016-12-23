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
            output["titleText"] = $(xml).find("#" + nodeID).find('#Title').find('tspan').text();
        }
        output["rightText"] = $(xml).find("#" + nodeID).find('#Right-Side').find('text').find('tspan:eq(0)').text();
        var imageUUID = $(xml).find("#" + nodeID).find('#Right-Side').find('g:eq(0)').attr('id');
        if (imageUUID !== undefined) {
            var imageProps = spec(imageUUID);
            if (typeof imageProps === "object" && imageProps.sourceName !== undefined) {
                output["rightImage"] = imageProps.sourceName;
            }
        }
        output["leftText"] = $(xml).find("#" + nodeID).find('#Left-Side').find('text').find('tspan:eq(0)').text();
        var imageUUID = $(xml).find("#" + nodeID).find('#Left-Side').find('g:eq(0)').attr('id');
        if (imageUUID !== undefined) {
            var imageProps = spec(imageUUID);
            if (typeof imageProps === "object" && imageProps.sourceName !== undefined) {
                output["leftImage"] = imageProps.sourceName;
            }
        }
        return output;
    },
}

UINavigationBar.defaultProps = function () {
    return {
        titleView: {
            value: ["Title", "Title_SubTitle", "Custom"],
            type: "Enum",
        }
    }
};

UINavigationBar.oc_class = function (props) {
    if (props.titleView === "Custom") {
        return "";
    }
    return undefined;
}

UINavigationBar.oc_viewDidLoad = function (props) {
    var code = "";
    if (props.titleView === "Title" && props.titleText !== undefined) {
        code += "self.title = @\"" + oc_text(props.titleText) + "\";\n";
    }
    else if (props.titleView === "Custom") {
        code += "self.navigationItem.titleView = [self titleView];\n";
    }
    if (props.rightText !== undefined && props.rightText.length > 0) {
        code += "self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@\"" + oc_text(props.rightText) + "\" style:UIBarButtonItemStylePlain target:nil action:nil];\n"
    }
    if (props.rightImage !== undefined && props.rightImage.length > 0) {
        code += "self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@\"" + props.rightImage + "\"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:nil action:nil];\n"
    }
    if (props.leftText !== undefined && props.leftText.length > 0) {
        code += "self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@\"" + oc_text(props.rightText) + "\" style:UIBarButtonItemStylePlain target:nil action:nil];\n"
    }
    if (props.leftImage !== undefined && props.leftImage.length > 0) {
        code += "self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@\"" + props.rightImage + "\"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:nil action:nil];\n"
    }
    return code;
}