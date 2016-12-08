@import "SketchLibrary.js"

//	Load Bundle

if($.runtime.classExists("MCFluidPluginController") == false){
    $.runtime.loadBundle($.paths.resourcesPath+"/Fluid.bundle");
    $.runtime.loadBundle($.paths.resourcesPath+"/components.bundle");
}

if($.runtime.classExists("COMPluginController") == false){
	$.runtime.loadBundle($.paths.resourcesPath+"/components.bundle");
}

//	Controller

var getPluginController = function(ctx){
	return [COMPluginController pluginController:ctx.plugin pluginCommand:ctx.command];
};