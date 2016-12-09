//
//  UISwitch/main.js
//  CodeX
//
//  Created by 崔明辉 on 2016/12/9.
//  Copyright © 2016年 UED Center. All rights reserved.
//

var UISwitch = {
    parse: function(nodeID, nodeXML, nodeProps) {
        var output = UIView.parse(nodeID, nodeXML, nodeProps);
        var xml = document.createElement('div');
        $(xml).html(nodeXML);
        output['onThumbColor'] = UISwitch.findOnThumbColor(nodeID, xml);
        return output;
    },
    findOnThumbColor: function(nodeID, xml) {
        return $(xml).find('#' + nodeID).find('#onBackground').attrs('fill', xml);
    },
}