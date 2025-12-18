// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!

function preview(){
	
    var date_object = getValue("dt_object");
    var custom_format = getValue("format_custom_input");
    var preset_format = getValue("format_preset_dropdown");
    var locale = getValue("locale_select");
    var r_command = "";
    var format_str = custom_format;
    if(!format_str){ format_str = preset_format; }
    if(date_object && format_str){
        if(locale){
            r_command += "local({ original_locale <- Sys.getlocale(\"LC_TIME\"); Sys.setlocale(\"LC_TIME\", \"" + locale + "\"); tryCatch({ ";
        }
        r_command += "format(" + date_object + ", format=\"" + format_str + "\")";
        if(locale){ r_command += " }, finally = { Sys.setlocale(\"LC_TIME\", original_locale) }) })"; }
    } else if (date_object && !format_str) { r_command = "stop(\"No format string provided.\")"; }
   if(r_command) { echo("preview_data <- data.frame(Result=" + r_command + ");\n"); }
}

function preprocess(is_preview){
	// add requirements etc. here

}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    var date_object = getValue("dt_object");
    var custom_format = getValue("format_custom_input");
    var preset_format = getValue("format_preset_dropdown");
    var locale = getValue("locale_select");
    var r_command = "";
    var format_str = custom_format;
    if(!format_str){ format_str = preset_format; }
    if(date_object && format_str){
        if(locale){
            r_command += "local({ original_locale <- Sys.getlocale(\"LC_TIME\"); Sys.setlocale(\"LC_TIME\", \"" + locale + "\"); tryCatch({ ";
        }
        r_command += "format(" + date_object + ", format=\"" + format_str + "\")";
        if(locale){ r_command += " }, finally = { Sys.setlocale(\"LC_TIME\", original_locale) }) })"; }
    } else if (date_object && !format_str) { r_command = "stop(\"No format string provided.\")"; }
   echo("formatted_dates <- " + r_command + ";\n");
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Format Dates as Text results")).print();	
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
			echo(".GlobalEnv$" + saveResult + " <- formatted_dates\n");
		}	
	}

}

