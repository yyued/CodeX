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

$.commands.createCommand("edit", function(ctx){
	var pluginController = getPluginController(ctx);
	pluginController.showProps();
});

$.commands.createCommand("publish", function(ctx){
	var pluginController = getPluginController(ctx);
	pluginController.showPublisher();
});

$.commands.createCommand("sidebar", function(ctx){
	var pluginController = getPluginController(ctx);
	pluginController.showSidebar();
});

$.commands.createCommand("library", function(ctx){
	var pluginController = getPluginController(ctx);
	pluginController.showLibraryChooser();
});