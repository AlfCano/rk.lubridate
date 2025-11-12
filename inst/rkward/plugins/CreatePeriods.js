// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(lubridate)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated
 var val = getValue("period_val"); var unit = getValue("period_unit"); echo("lubridate_period <- lubridate::" + unit + "(" + val + ");\n"); 
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Create Periods results")).print();
 var save_name = getValue("save_period.objectname"); echo("rk.header(\"Create Period Results\")\n"); echo("rk.header(\"Result saved to object: " + save_name + "\", level=3)\n"); 
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

