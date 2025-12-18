// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!

function preview(){
	 var val = getValue("period_val"); var unit = getValue("period_unit"); var r_command = "lubridate::" + unit + "(" + val + ")";  echo("preview_data <- data.frame(Result=as.character(" + r_command + "));\n");
}

function preprocess(is_preview){
	// add requirements etc. here
	if(is_preview) {
		echo("if(!base::require(lubridate)){stop(" + i18n("Preview not available, because package lubridate is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(lubridate)\n");
	}
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated
 var val = getValue("period_val"); var unit = getValue("period_unit"); var r_command = "lubridate::" + unit + "(" + val + ")";  echo("lubridate_period <- " + r_command + ";\n");
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Create Periods results")).print();	
	} var save_name = getValue("save_period.objectname"); echo("rk.header(\"Create Period Results\")\n"); if(getValue("save_period.active")){ echo("rk.header(\"Result saved to object: " + save_name + "\", level=3)\n"); } 
	if(!is_preview) {
		//// save result object
		// read in saveobject variables
		var savePeriod = getValue("save_period");
		var savePeriodActive = getValue("save_period.active");
		var savePeriodParent = getValue("save_period.parent");
		// assign object to chosen environment
		if(savePeriodActive) {
			echo(".GlobalEnv$" + savePeriod + " <- lubridate_period\n");
		}	
	}

}

