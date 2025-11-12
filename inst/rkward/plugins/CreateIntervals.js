// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(lubridate)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

      var start = getValue("interval_start");
      var end = getValue("interval_end");
      var output_type = getValue("output_type_radio");
      var unit = getValue("unit_select");

      if(start && end){
        var core_interval = "lubridate::interval(" + start + ", " + end + ")";
        var final_code = "";

        if(output_type == "period"){
            final_code = "as.period(" + core_interval + ", unit=\"" + unit + "\")";
        } else if(output_type == "length"){
            final_code = "lubridate::time_length(" + core_interval + ", unit=\"" + unit + "\")";
        } else {
            final_code = core_interval;
        }
        echo("lubridate_interval <- " + final_code + "\n");
      }
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Create Intervals results")).print();

    var save_name = getValue("save_interval.objectname");
    echo("rk.header(\"Create Interval Results\")\n");
    echo("rk.header(\"Result saved to object: " + save_name + "\", level=3)\n");
  
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

