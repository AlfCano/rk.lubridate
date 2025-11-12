// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(lubridate)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    var date_source = getValue("parse_varslot");
    if(!date_source){
        date_source = getValue("parse_manual_input");
    }

    if(date_source){
        var order = getValue("parse_order");
        var tz = getValue("parse_tz");
        var code = "lubridate_result <- lubridate::" + order + "(" + date_source;
        if(tz) {
            code += ", tz=\"" + tz + "\"";
        }
        code += ");\n";
        echo(code);
    } else {
        echo("rk.stop(\"No data source provided. Please select an object or enter a vector manually.\")");
    }
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Parse Date-Times with lubridate results")).print();

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

