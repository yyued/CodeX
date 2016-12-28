//
//  UITableViewCell/main.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/12.
//  Copyright © 2016年 UED Center. All rights reserved.
//

var UITableViewCell = {
    parse: function (nodeID, nodeXML, nodeProps) {
        var output = UIView.parse(nodeID, nodeXML, nodeProps);
        var xml = $.create(nodeXML);
        return output;
    },
}

UITableViewCell.defaultProps = function () {
    return Object.assign(UIView.defaultProps(), {
        reuseIdentifier: {
            value: undefined,
            type: "String",
        }
    })
};

UITableViewCell.oc_class = function (props) {
    return "UIView";
}

UITableViewCell.oc_code = function (props) {
    var code = "";
    code += oc_init("UIView", "view");
    code += UITableViewCell.oc_codeWithProps(props);
    return code;
}

UITableViewCell.oc_codeWithProps = function (props) {
    var code = UIView.oc_codeWithProps(props);
    return code;
}

// UITableViewCell.xib_code = function (id, layer) {
//     var xml = $.xml('<view contentMode="scaleToFill"></view>');
//     $(xml).find(':first').attr('id', id);
//     $(xml).find(':first').attr('customClass', "COXUITableViewCell");
//     UITableViewCell.xib_codeWithProps(id, layer.props, xml);
//     UIView.xib_addSublayers(layer, xml);
//     return $(xml).html();
// }

// UITableViewCell.xib_codeWithProps = function (id, props, xml) {
//     UIView.xib_codeWithProps(props, xml);
//     if (props.text !== undefined) {
//         if ($(xml).find(':first').find('subviews').length == 0) {
//             $(xml).find(':first').append('<subviews></subviews>');
//         }
//         $(xml).find(':first').find('subviews:eq(0)').append(
//             window["UILabel"].xib_code(id + "-TEXT", {
//                 class: "UILabel",
//                 id: id + "-TEXT",
//                 props: Object.assign(props.text, {tag: -1}),
//             })
//         )
//     }
// }