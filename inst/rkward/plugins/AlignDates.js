// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!

function preview(){
	
    var dt = getValue("dt_object"); var act = getValue("align_act");
    var r_command = "";
    if(act == "rollback") r_command = "lubridate::rollback(" + dt + ")";
    else if(act == "floor") r_command = "lubridate::floor_date(" + dt + ", unit=\"month\")";
    else if(act == "ceiling") r_command = "lubridate::ceiling_date(" + dt + ", unit=\"month\") - lubridate::days(1)";
    else r_command = "lubridate::days_in_month(" + dt + ")";
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

    var dt = getValue("dt_object"); var act = getValue("align_act");
    var r_command = "";
    if(act == "rollback") r_command = "lubridate::rollback(" + dt + ")";
    else if(act == "floor") r_command = "lubridate::floor_date(" + dt + ", unit=\"month\")";
    else if(act == "ceiling") r_command = "lubridate::ceiling_date(" + dt + ", unit=\"month\") - lubridate::days(1)";
    else r_command = "lubridate::days_in_month(" + dt + ")";
   echo("aligned_date <- " + r_command + ";\n");
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Align Dates results")).print();	
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
			echo(".GlobalEnv$" + saveResult + " <- aligned_date\n");
		}	
	}

}

