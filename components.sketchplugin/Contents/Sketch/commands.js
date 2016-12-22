@import "main.js"

//	--------
//	COMMANDS
//	--------

$.commands.createCommand("add", function(ctx){
	var pluginController = getPluginController(ctx);
	pluginController.showDialog(false);
});

$.commands.createCommand("replace", function(ctx){
	var pluginController = getPluginController(ctx);
	pluginController.showDialog(true);
});

$.commands.createCommand("sidebar", function(ctx){
	var pluginController = getPluginController(ctx);
	pluginController.showSidebar();
});

$.commands.createCommand("library", function(ctx){
	var pluginController = getPluginController(ctx);
	pluginController.showLibraryChooser();
});

$.commands.createCommand("updatelayout", function(ctx){
	var pluginController = [MCFluidPluginController pluginController:ctx.plugin pluginCommand:ctx.command];
	pluginController.updateLayout();
});

$.commands.createCommand("addBounds", function(ctx){
	var pluginController = getPluginController(ctx);
	pluginController.addBounds();
});
