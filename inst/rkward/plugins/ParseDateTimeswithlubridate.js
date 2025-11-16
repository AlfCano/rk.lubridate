// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!

function preview(){
	
    var manual_input = getValue("parse_manual_input");
    var date_source;
    var r_command;

    if(manual_input){
        date_source = manual_input;
    } else {
        date_source = getValue("parse_varslot");
    }

    if(date_source){
        var order = getValue("parse_order");
        var tz = getValue("parse_tz");
        r_command = "lubridate::" + order + "(" + date_source;
        if(tz) {
            r_command += ", tz=\"" + tz + "\"";
        }
        r_command += ")";
    } else {
        r_command = "stop(\"No data source provided. Please select an object or enter a vector manually.\")";
    }
   echo("preview_data <- data.frame(Result=" + r_command + ");\n");
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

    var manual_input = getValue("parse_manual_input");
    var date_source;
    var r_command;

    if(manual_input){
        date_source = manual_input;
    } else {
        date_source = getValue("parse_varslot");
    }

    if(date_source){
        var order = getValue("parse_order");
        var tz = getValue("parse_tz");
        r_command = "lubridate::" + order + "(" + date_source;
        if(tz) {
            r_command += ", tz=\"" + tz + "\"";
        }
        r_command += ")";
    } else {
        r_command = "stop(\"No data source provided. Please select an object or enter a vector manually.\")";
    }
   echo("lubridate_result <- " + r_command + ";\n");
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Parse Date-Times with lubridate results")).print();	
	}
    var save_name = getValue("save_result.objectname");
    echo("rk.header(\"lubridate Operation Results\")\n");
    if(getValue("save_result.active")){
      echo("rk.header(\"Result saved to object: " + save_name + "\", level=3)\n");
    }
  
	if(!is_preview) {
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

}

