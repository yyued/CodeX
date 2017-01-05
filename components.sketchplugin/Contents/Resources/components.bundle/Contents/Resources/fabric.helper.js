var loadSVG = function(xml, callback){
    fabric.loadSVGFromString(xml, function(objects, options){
                             var objs = [];
                             for (var i = 0; i < objects.length; i++) {
                                objs.push(objects[i].toJSON());
                             }
                             if (typeof callback === "function") {
                                callback(objs, options);
                             }
                             });
};
