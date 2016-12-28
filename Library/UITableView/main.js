//
//  UITableView/main.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/12.
//  Copyright © 2016年 UED Center. All rights reserved.
//

var UITableView = {
    parse: function (nodeID, nodeXML, nodeProps) {
        var output = UIView.parse(nodeID, nodeXML, nodeProps);
        var xml = $.create(nodeXML);
        var reuseIdentifiers = {};
        $(xml).find('#' + nodeID).find('g').each(function () {
            var props = spec($(this).attr('id'));
            if (props !== undefined && props["class"] === "UITableViewCell" && props["reuseIdentifier"] !== undefined) {
                reuseIdentifiers[props["reuseIdentifier"]] = true;
            }
        });
        output["reuseIdentifiers"] = Object.keys(reuseIdentifiers);
        return output;
    },
}

UITableView.defaultProps = function () {
    return Object.assign(UIScrollView.defaultProps(), {
    })
};

UITableView.oc_viewDidLoad = function (props) {
    if (props.adjustInset === true) {
        return "self.automaticallyAdjustsScrollViewInsets = YES;\n";
    }
    else {
        return "self.automaticallyAdjustsScrollViewInsets = NO;\n";
    }
}

UITableView.oc_class = function (props) {
    return "UITableView";
}

UITableView.oc_code = function (props) {
    var code = "";
    code += "UITableView *view = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];\n";
    code += UITableView.oc_codeWithProps(props);
    return code;
}

UITableView.oc_codeWithProps = function (props) {
    var code = UIScrollView.oc_codeWithProps(props);
    if (props.reuseIdentifiers !== undefined) {
        for (var index = 0; index < props.reuseIdentifiers.length; index++) {
            var element = props.reuseIdentifiers[index];
            code += "[view registerClass:NSClassFromString(@\"" + element + "\") forCellReuseIdentifier:@\"" + element + "\"];\n";
        }
    }
    return code;
}

UITableView.xib_code = function (id, layer) {
    var xml = $.xml('<tableView clipsSubviews="YES" contentMode="scaleToFill" alwaysBounceVertical="YES" style="plain" separatorStyle="default" rowHeight="44"></tableView>');
    $(xml).find(':first').attr('id', id);
    $(xml).find(':first').attr('customClass', "UITableView");
    UITableView.xib_codeWithProps(layer.props, xml);
    return $(xml).html();
}

UITableView.xib_codeWithProps = function (props, xml) {
    UIView.xib_codeWithProps(props, xml);
    if (props.reuseIdentifiers !== undefined) {
        for (var index = 0; index < props.reuseIdentifiers.length; index++) {
            var element = props.reuseIdentifiers[index];
            $(xml).find(':first').find('userDefinedRuntimeAttributes:eq(0)').append('<userDefinedRuntimeAttribute type="string" keyPath="cox_reuseIdentifier" value="' + element + '"/>');
        }
    }
}