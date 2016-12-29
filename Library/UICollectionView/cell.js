//
//  UICollectionViewCell/main.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/12.
//  Copyright © 2016年 UED Center. All rights reserved.
//

var UICollectionViewCell = {
    parse: function (nodeID, nodeXML, nodeProps) {
        var output = UIReusableView.parse(nodeID, nodeXML, nodeProps);
        var xml = $.create(nodeXML);
        return output;
    },
}

UICollectionViewCell.defaultProps = function () {
    return Object.assign(UIReusableView.defaultProps(), {
        reuseClass: {
            value: "COXCollectionViewCell",
            type: "String",
        }
    })
};

UICollectionViewCell.oc_class = function (props) {
    return "UIView";
}

UICollectionViewCell.oc_code = function (props) {
    var code = "";
    code += oc_init("UIView", "view");
    code += UICollectionViewCell.oc_codeWithProps(props);
    return code;
}

UICollectionViewCell.oc_codeWithProps = function (props) {
    var code = UIReusableView.oc_codeWithProps(props);
    return code;
}