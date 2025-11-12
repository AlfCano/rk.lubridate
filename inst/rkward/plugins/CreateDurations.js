// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(lubridate)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated
 var val = getValue("duration_val"); var unit = getValue("duration_unit"); echo("lubridate_duration <- lubridate::" + unit + "(" + val + ");\n"); 
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Create Durations results")).print();
 var save_name = getValue("save_duration.objectname"); echo("rk.header(\"Create Duration Results\")\n"); echo("rk.header(\"Result saved to object: " + save_name + "\", level=3)\n"); 
	//// save result object
	// read in saveobject variables
	var saveDuration = getValue("save_duration");
	var saveDurationActive = getValue("save_duration.active");
	var saveDurationParent = getValue("save_duration.parent");
	// assign object to chosen environment
	if(saveDurationActive) {
		echo(".GlobalEnv$" + saveDuration + " <- lubridate_duration\n");
	}

}

