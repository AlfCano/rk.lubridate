// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!

function preview(){
	
      var start = getValue("interval_start");
      var end = getValue("interval_end");
      var output_type = getValue("output_type_radio");
      var unit = getValue("unit_select");
      var r_command = "";

      if(start && end){
        var core_interval = "lubridate::interval(" + start + ", " + end + ")";
        if(output_type == "period"){
            r_command = "as.period(" + core_interval + ", unit=\"" + unit + "\")";
        } else if(output_type == "length"){
            r_command = "lubridate::time_length(" + core_interval + ", unit=\"" + unit + "\")";
        } else {
            r_command = core_interval;
        }
      }
   if(r_command) { echo("preview_data <- data.frame(Result=as.character(" + r_command + "));\n"); }
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

      var start = getValue("interval_start");
      var end = getValue("interval_end");
      var output_type = getValue("output_type_radio");
      var unit = getValue("unit_select");
      var r_command = "";

      if(start && end){
        var core_interval = "lubridate::interval(" + start + ", " + end + ")";
        if(output_type == "period"){
            r_command = "as.period(" + core_interval + ", unit=\"" + unit + "\")";
        } else if(output_type == "length"){
            r_command = "lubridate::time_length(" + core_interval + ", unit=\"" + unit + "\")";
        } else {
            r_command = core_interval;
        }
      }
   if(r_command) { echo("lubridate_interval <- " + r_command + ";\n"); }
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Create Intervals results")).print();	
	}
    var save_name = getValue("save_interval.objectname");
    echo("rk.header(\"Create Interval Results\")\n");
    if(getValue("save_interval.active")){
      echo("rk.header(\"Result saved to object: " + save_name + "\", level=3)\n");
    }
  
	if(!is_preview) {
		//// save result object
		// read in saveobject variables
		var saveInterval = getValue("save_interval");
		var saveIntervalActive = getValue("save_interval.active");
		var saveIntervalParent = getValue("save_interval.parent");
		// assign object to chosen environment
		if(saveIntervalActive) {
			echo(".GlobalEnv$" + saveInterval + " <- lubridate_interval\n");
		}	
	}

}

