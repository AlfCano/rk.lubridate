// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!

function preview(){
	
    var dt = getValue("shift_date_obj");
    var op = getValue("shift_op");
    var val = getValue("shift_val");
    var unit = getValue("shift_unit");
    var type = getValue("shift_type");
    var roll = getValue("shift_roll");

    var time_obj = "";
    if (type == "period") { time_obj = "lubridate::period(" + val + ", units=\"" + unit + "\")"; }
    else { time_obj = "lubridate::duration(" + val + ", units=\"" + unit + "\")"; }

    var operator = "";
    // Logic for rollover operator (%m+% / %m-%) which only works with periods
    if (roll == "1" && type == "period" && (unit == "months" || unit == "years")) {
         operator = (op == "add") ? "%m+%" : "%m-%";
    } else {
         operator = (op == "add") ? "+" : "-";
    }

    var r_command = dt + " " + operator + " " + time_obj;
   echo("preview_data <- data.frame(Result=as.character(" + r_command + "));\n");
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

    var dt = getValue("shift_date_obj");
    var op = getValue("shift_op");
    var val = getValue("shift_val");
    var unit = getValue("shift_unit");
    var type = getValue("shift_type");
    var roll = getValue("shift_roll");

    var time_obj = "";
    if (type == "period") { time_obj = "lubridate::period(" + val + ", units=\"" + unit + "\")"; }
    else { time_obj = "lubridate::duration(" + val + ", units=\"" + unit + "\")"; }

    var operator = "";
    // Logic for rollover operator (%m+% / %m-%) which only works with periods
    if (roll == "1" && type == "period" && (unit == "months" || unit == "years")) {
         operator = (op == "add") ? "%m+%" : "%m-%";
    } else {
         operator = (op == "add") ? "+" : "-";
    }

    var r_command = dt + " " + operator + " " + time_obj;
   echo("shifted_date <- " + r_command + ";\n");
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Shift Dates results")).print();	
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
			echo(".GlobalEnv$" + saveResult + " <- shifted_date\n");
		}	
	}

}

