// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(lubridate)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated
 var dt_object = getValue("dt_object"); if(dt_object){ var comp = getValue("get_comp"); var label = getValue("get_label.state"); var code = "lubridate_result <- lubridate::" + comp + "(" + dt_object; if(label == 1){ code += ", label=TRUE"; } code += ");\n"; echo(code); } 
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Get Component from Date results")).print();

    var save_name = getValue("save_result.objectname");
    echo("rk.header(\"lubridate Operation Results\")\n");
    echo("rk.header(\"Result saved to object: " + save_name + "\", level=3)\n");
  
	//// save result object
	// read in saveobject variables
	var saveResult = getValue("save_result");
	var saveResultActive = getValue("save_result.active");
	var saveResultParent = getValue("save_result.parent");
	// assign object to chosen environment
	if(saveResultActive) {
		echo(".GlobalEnv$" + saveResult + " <- lubridate_result\n");
	}

}

