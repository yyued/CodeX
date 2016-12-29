//
//  UICollectionView/main.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/12.
//  Copyright © 2016年 UED Center. All rights reserved.
//

var UICollectionView = {
    parse: function (nodeID, nodeXML, nodeProps) {
        var output = UIView.parse(nodeID, nodeXML, nodeProps);
        var xml = $.create(nodeXML);
        var reuseIdentifiers = {};
        $(xml).find('#' + nodeID).find('g').each(function () {
            var props = spec($(this).attr('id'));
            if (props !== undefined && props["class"] === "UICollectionViewCell" && props["reuseIdentifier"] !== undefined) {
                reuseIdentifiers[props["reuseIdentifier"]] = true;
            }
        });
        output["reuseIdentifiers"] = Object.keys(reuseIdentifiers);
        return output;
    },
}

UICollectionView.defaultProps = function () {
    return Object.assign(UIScrollView.defaultProps(), {
        layoutDirection: {
            value: ["Vertical", "Horizontal"],
            type: "Enum",
        }
    })
};

UICollectionView.oc_viewDidLoad = function (props) {
    if (props.adjustInset === true) {
        return "self.automaticallyAdjustsScrollViewInsets = YES;\n";
    }
    else {
        return "self.automaticallyAdjustsScrollViewInsets = NO;\n";
    }
}

UICollectionView.oc_class = function (props) {
    return "UICollectionView";
}

UICollectionView.oc_code = function (props) {
    var code = "";
    code += "UICollectionView *view = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[UICollectionViewFlowLayout new]];\n";
    code += UICollectionView.oc_codeWithProps(props);
    return code;
}

UICollectionView.oc_codeWithProps = function (props) {
    var code = UIScrollView.oc_codeWithProps(props);
    if (props.layoutDirection === "Horizontal") {
        code += "[(UICollectionViewFlowLayout *)view.collectionViewLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];\n";
        code += "view.alwaysBounceHorizontal = YES;"
    }
    else {
        code += "view.alwaysBounceVertical = YES;"
    }
    if (props.reuseIdentifiers !== undefined) {
        for (var index = 0; index < props.reuseIdentifiers.length; index++) {
            var element = props.reuseIdentifiers[index];
            code += "[view registerClass:NSClassFromString(@\"" + element + "\") forCellWithReuseIdentifier:@\"" + element + "\"];\n";
        }
    }
    return code;
}

UICollectionView.xib_code = function (id, layer) {
    var xml = $.xml('<collectionView clipsSubviews="YES" multipleTouchEnabled="YES" contentMode="scaleToFill"></collectionView>');
    $(xml).find(':first').attr('id', id);
    $(xml).find(':first').attr('customClass', "UICollectionView");
    UICollectionView.xib_codeWithProps(layer.props, xml);
    return $(xml).html();
}

UICollectionView.xib_codeWithProps = function (props, xml) {
    UIView.xib_codeWithProps(props, xml);
    $(xml).find(':first').append('<collectionViewFlowLayout key="collectionViewLayout" minimumLineSpacing="10" minimumInteritemSpacing="10" id="'+xib_uuid()+'"><size key="itemSize" width="50" height="50"/><size key="headerReferenceSize" width="0.0" height="0.0"/><size key="footerReferenceSize" width="0.0" height="0.0"/><inset key="sectionInset" minX="0.0" minY="0.0" maxX="0.0" maxY="0.0"/></collectionViewFlowLayout>');
    if (props.layoutDirection === "Horizontal") {
        $(xml).find(':first').find('collectionViewFlowLayout').attr("scrollDirection", "horizontal");
    }
    if (props.reuseIdentifiers !== undefined) {
        for (var index = 0; index < props.reuseIdentifiers.length; index++) {
            var element = props.reuseIdentifiers[index];
            $(xml).find(':first').find('userDefinedRuntimeAttributes:eq(0)').append('<userDefinedRuntimeAttribute type="string" keyPath="cox_reuseIdentifier" value="' + element + '"/>');
        }
    }
}