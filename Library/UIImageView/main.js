//
//  UIImageView/main.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/12.
//  Copyright © 2016年 UED Center. All rights reserved.
//

var UIImageView = {
    parse: function (nodeID, nodeXML, nodeProps) {
        var output = UIView.parse(nodeID, nodeXML, nodeProps);
        var xml = $.create(nodeXML);
        if (nodeProps.sourceType === "Local") {
            var fileData = $(xml).find('#' + nodeID).find('image').attrs('xlink:href', xml);
            if (fileData !== undefined) {
                fileData = fileData.split('data:image/png;base64,')[1];
            }
            else {
                var fill = $(xml).find('#' + nodeID).find('#Bitmap').attrs('fill', xml);
                if (fill !== undefined) {
                    fill = fill.replace('url(', '').replace(')', '');
                    var href = $(xml).find(fill).find('use').attrs('xlink:href', xml);
                    if (href !== undefined) {
                        fileData = $(xml).find(href).attrs('xlink:href', xml);
                        if (fileData !== undefined) {
                            fileData = fileData.split('data:image/png;base64,')[1];
                        }
                    }
                }
            }
            output["fileData"] = fileData;
        }
        else if (nodeProps.sourceType === "Remote") {
            var fileData = $(xml).find('#' + nodeID).find('#Placeholder').attrs('xlink:href', xml);
            if (fileData !== undefined) {
                fileData = fileData.split('data:image/png;base64,')[1];
            }
            output["placeholderData"] = fileData;
        }
        return output;
    },
}

UIImageView.defaultProps = function () {
    return Object.assign(UIView.defaultProps(), {
        sourceType: {
            value: ["Local", "Remote", "Shape"],
            type: "Enum",
        },
    })
};

UIImageView.oc_class = function (props) {
    return "UIImageView";
}

UIImageView.oc_code = function (props) {
    var code = "";
    code += oc_init("UIImageView", "view");
    code += UIImageView.oc_codeWithProps(props);
    return code;
}

UIImageView.oc_codeWithProps = function (props) {
    var code = UIView.oc_codeWithProps(props);
    if (props.sourceType === "Local") {
        if (props.fileData !== undefined && props.sourceName !== undefined) {
            oc_writeAssets(props.fileData, props.frame.width, props.frame.height, props.sourceName);
            var sourceName = props.sourceName;
            sourceName = sourceName.split('/').pop();
            code += "view.image = [UIImage imageNamed:@\"" + sourceName + "\"];\n";
        }
    }
    else if (props.sourceType === "Shape") {
        if (props.sourceName !== undefined) {
            var sourceName = props.sourceName;
            sourceName = sourceName.split('/').pop();
            code += "view.image = [UIImage imageNamed:@\"" + sourceName + "\"];\n";
        }
    }
    else if (props.sourceType === "Remote") {
        if (props.placeholderData !== undefined && props.sourceName !== undefined) {
            oc_writeAssets(props.placeholderData, props.frame.width, props.frame.height, props.sourceName);
            var sourceName = props.sourceName;
            sourceName = sourceName.split('/').pop();
            code += "view.image = [UIImage imageNamed:@\"" + sourceName + "\"];\n";
        }
    }
    return code;
}