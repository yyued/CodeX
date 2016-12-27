//
//  UIPageControl/main.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/12.
//  Copyright © 2016年 UED Center. All rights reserved.
//

var UIPageControl = {
    parse: function (nodeID, nodeXML, nodeProps) {
        var output = UIView.parse(nodeID, nodeXML, nodeProps);
        var xml = $.create(nodeXML);
        var currentPageIndicatorTintColor = $(xml).find('#' + nodeID).find('#Indicators').find('circle#1').attrs('fill', xml);
        var currentPageIndicatorTintColorAlpha = $(xml).find('#' + nodeID).find('#Indicators').find('circle#1').attrs('fill-opacity', xml);
        var pageIndicatorTintColor = $(xml).find('#' + nodeID).find('#Indicators').find('circle#5').attrs('fill', xml);
        var pageIndicatorTintColorAlpha = $(xml).find('#' + nodeID).find('#Indicators').find('circle#5').attrs('fill-opacity', xml);
        if (pageIndicatorTintColor !== undefined) {
            if (pageIndicatorTintColorAlpha !== undefined) {
                pageIndicatorTintColor = colorWithAlpha(pageIndicatorTintColor, parseFloat(pageIndicatorTintColorAlpha));
            }
            output["pageIndicatorTintColor"] = pageIndicatorTintColor;
        }
        if (currentPageIndicatorTintColor !== undefined) {
            if (currentPageIndicatorTintColorAlpha !== undefined) {
                currentPageIndicatorTintColor = colorWithAlpha(currentPageIndicatorTintColor, parseFloat(currentPageIndicatorTintColorAlpha));
            }
            output["currentPageIndicatorTintColor"] = currentPageIndicatorTintColor;
        }
        return output;
    },
}

UIPageControl.defaultProps = function() {
    return Object.assign(UIView.defaultProps(), {
    })
};

UIPageControl.oc_class = function (props) {
    return "UIPageControl";
}

UIPageControl.oc_code = function (props) {
    var code = "";
    code += oc_init("UIPageControl", "view");
    code += UIPageControl.oc_codeWithProps(props);
    return code;
}

UIPageControl.oc_codeWithProps = function (props) {
    var code = UIView.oc_codeWithProps(props);
    if (props.pageIndicatorTintColor !== undefined) {
        code += "view.pageIndicatorTintColor = " + oc_color(props.pageIndicatorTintColor) + ";\n";
    }
    if (props.currentPageIndicatorTintColor !== undefined) {
        code += "view.currentPageIndicatorTintColor = " + oc_color(props.currentPageIndicatorTintColor) + ";\n";
    }
    code += "view.numberOfPages = 5;\n";
    return code;    
}

UIPageControl.xib_code = function (id, layer) {
    var xml = $.xml('<view contentMode="scaleToFill"></view>');
    $(xml).find(':first').attr('id', id);
    $(xml).find(':first').attr('customClass', "UIPageControl");
    UIPageControl.xib_codeWithProps(layer.props, xml);
    UIView.xib_addSublayers(layer, xml);
    return $(xml).html();
}

UIPageControl.xib_codeWithProps = function (props, xml) {
    UIView.xib_codeWithProps(props, xml);
    $(xml).find(':first').find('userDefinedRuntimeAttributes:eq(0)').append('<userDefinedRuntimeAttribute type="number" keyPath="numberOfPages"><integer key="value" value="5"/></userDefinedRuntimeAttribute>');
    if (props.pageIndicatorTintColor !== undefined) {
        $(xml).find(':first').find('userDefinedRuntimeAttributes:eq(0)').append('<userDefinedRuntimeAttribute type="color" keyPath="pageIndicatorTintColor">' + xib_color('value', props.pageIndicatorTintColor) + '</userDefinedRuntimeAttribute>');
    }
    if (props.currentPageIndicatorTintColor !== undefined) {
        $(xml).find(':first').find('userDefinedRuntimeAttributes:eq(0)').append('<userDefinedRuntimeAttribute type="color" keyPath="currentPageIndicatorTintColor">' + xib_color('value', props.currentPageIndicatorTintColor) + '</userDefinedRuntimeAttribute>');
    }
}